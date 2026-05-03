import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/providers/user/user_notifier.dart';

import 'challenge_repository.dart';

/// Translates Firebase errors into user-friendly Arabic messages
String _firebaseErrorMessage(dynamic e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'too-many-requests':
      case 'resource-exhausted':
        return '⚠️ السيرفر ممتلئ حالياً، حاول مجدداً بعد قليل.';
      case 'service-unavailable':
      case 'unavailable':
        return '🔧 الخادم غير متاح مؤقتاً، حاول مجدداً لاحقاً.';
      case 'network-request-failed':
        return '📶 تحقق من اتصالك بالإنترنت وحاول مجدداً.';
      case 'permission-denied':
        return '🔒 ليس لديك صلاحية القيام بهذا الإجراء.';
      case 'disconnected':
        return '🔌 انقطع الاتصال بالسيرفر، حاول مجدداً.';
      default:
        return '⚠️ السيرفر ممتلئ أو غير متاح حالياً، حاول مجدداً.';
    }
  }
  final msg = e.toString().toLowerCase();
  if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
    return '📶 تحقق من اتصالك بالإنترنت وحاول مجدداً.';
  }
  if (msg.contains('timeout') || msg.contains('timed out')) {
    return '⏳ استغرق الطلب وقتاً طويلاً، السيرفر قد يكون مشغولاً.';
  }
  return '⚠️ السيرفر ممتلئ أو غير متاح حالياً، حاول مجدداً.';
}

final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  return MatchmakingService(ref);
});

class MatchmakingService {
  final Ref _ref;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  DatabaseReference? _currentQueueRef;
  StreamSubscription? _queueSub;
  Timer? _botTimer;

  MatchmakingService(this._ref);

  Future<void> cancelSearch() async {
    _botTimer?.cancel();
    _botTimer = null;
    _queueSub?.cancel();
    _queueSub = null;

    if (_currentQueueRef != null) {
      await _currentQueueRef!.onDisconnect().cancel();
      await _currentQueueRef!.remove();
      _currentQueueRef = null;
    }
  }

  // Generate a random 4-digit code
  String _generateCode() {
    final rnd = Random();
    return (rnd.nextInt(9000) + 1000).toString();
  }

  Future<String> createPrivateMatch(int unitId, String courseTitle) async {
    final user = _ref.read(userNotifierProvider).value;
    if (user == null) throw Exception('User not logged in');
    final String myUid = user.id.toString();

    final code = _generateCode();
    final matchRef = _db.child('challenges/matches').push();
    final matchId = matchRef.key!;

    final challengeRepo = _ref.read(challengeRepositoryProvider);
    final questionsData = await challengeRepo.getQuestions(unitId);
    final questionsList = (questionsData['questions'] as List?) ?? [];

    await matchRef.set({
      'status': 'waiting_for_opponent',
      'courseTitle': courseTitle,
      'unitId': unitId,
      'isPrivate': true,
      'inviteCode': code,
      'players': {
        myUid: {
          'uid': myUid,
          'name': user.name,
          'avatar': user.completeProfilePic,
          'badgeIconUrl': user.badge?.completeIconUrl,
          'badgeColor': user.badge?.color,
          'score': 0,
          'status': 'ready',
          'emoji': '',
        },
      },
      'questions': questionsList,
      'currentQuestionIndex': 0,
      'createdAt': ServerValue.timestamp,
    });

    // Map code to matchId for quick lookup
    await _db.child('challenges/private_codes/$code').set(matchId);
    // Clean up if creator disconnects before anyone joins
    await _db.child('challenges/private_codes/$code').onDisconnect().remove();
    await matchRef.onDisconnect().remove();

    return code;
  }

  Future<String?> joinPrivateMatch(String code) async {
    final user = _ref.read(userNotifierProvider).value;
    if (user == null) throw Exception('User not logged in');
    final String myUid = user.id.toString();

    final codeSnap = await _db.child('challenges/private_codes/$code').get();
    if (!codeSnap.exists) {
      throw Exception('الكود غير صحيح أو انتهت صلاحيته');
    }

    final matchId = codeSnap.value as String;
    final matchRef = _db.child('challenges/matches/$matchId');
    final matchSnap = await matchRef.get();

    if (!matchSnap.exists) {
      throw Exception('المباراة لم تعد موجودة');
    }

    final data = matchSnap.value as Map<dynamic, dynamic>;
    if (data['players'].length >= 2) {
      throw Exception('هذه الغرفة مكتملة بالفعل');
    }

    // Join match
    await matchRef.child('players/$myUid').set({
      'uid': myUid,
      'name': user.name,
      'avatar': user.completeProfilePic,
      'badgeIconUrl': user.badge?.completeIconUrl,
      'badgeColor': user.badge?.color,
      'score': 0,
      'status': 'ready',
      'emoji': '',
    });

    await matchRef.update({
      'status': 'starting',
    });

    // Remove the code since match started
    await _db.child('challenges/private_codes/$code').remove();
    await matchRef
        .onDisconnect()
        .cancel(); // Don't remove anymore, match is live

    return matchId;
  }

  Future<String?> findMatchOrJoinQueue(int unitId, String courseTitle) async {
    final user = _ref.read(userNotifierProvider).value;
    if (user == null) throw Exception('User not logged in');

    final String myUid = user.id.toString();
    final String queuePath = 'challenges/queue/$unitId';

    // 1. Setup Timeout for Bot Match (10 seconds) - Before any network calls
    final completer = Completer<String?>();
    _botTimer = Timer(const Duration(seconds: 10), () async {
      if (!completer.isCompleted) {
        _queueSub?.cancel();
        _currentQueueRef?.onDisconnect().cancel();
        if (_currentQueueRef != null) {
          _currentQueueRef!.remove();
        }
        _currentQueueRef = null;

        try {
          final botMatchId = await _createBotMatch(
              unitId, courseTitle, myUid, user.name, user.completeProfilePic);
          if (!completer.isCompleted) completer.complete(botMatchId);
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(Exception(_firebaseErrorMessage(e)));
        }
      }
    });

    try {
      // 2. Check if there's someone in queue
      final snapshot =
          await _db.child(queuePath).orderByKey().limitToFirst(1).get();

      if (snapshot.exists && snapshot.value != null) {
        final map = snapshot.value as Map<dynamic, dynamic>;
        final opponentKey = map.keys.first as String;
        final opponentData = map[opponentKey] as Map<dynamic, dynamic>;

        if (opponentData['uid'] != myUid) {
          // Found opponent, remove them from queue and create a match
          await _db.child(queuePath).child(opponentKey).remove();

          // Generate match ID
          final matchId = _db.child('challenges/matches').push().key!;

          // Fetch questions from backend
          final challengeRepo = _ref.read(challengeRepositoryProvider);
          final questionsData = await challengeRepo.getQuestions(unitId);
          final questionsList = (questionsData['questions'] as List?) ?? [];

          // Create Match in Firebase
          await _db.child('challenges/matches/$matchId').set({
            'status': 'starting',
            'courseTitle': courseTitle,
            'unitId': unitId,
            'players': {
              myUid: {
                'uid': myUid,
                'name': user.name,
                'avatar': user.completeProfilePic,
                'badgeIconUrl': user.badge?.completeIconUrl,
                'badgeColor': user.badge?.color,
                'score': 0,
                'status': 'ready',
                'emoji': '',
              },
              opponentData['uid']: {
                'uid': opponentData['uid'],
                'name': opponentData['name'],
                'avatar': opponentData['avatar'],
                'badgeIconUrl': opponentData['badgeIconUrl'],
                'badgeColor': opponentData['badgeColor'],
                'score': 0,
                'status': 'ready',
                'emoji': '',
              },
            },
            'questions': questionsList,
            'currentQuestionIndex': 0,
            'createdAt': ServerValue.timestamp,
          });

          await _db.child('challenges/queue_responses/$opponentKey').set({
            'matchId': matchId,
          });

          if (!completer.isCompleted) {
            _botTimer?.cancel();
            completer.complete(matchId);
          }
          return completer.future;
        }
      }

      // 3. No opponent found, join queue
      final myQueueRef = _db.child(queuePath).push();
      _currentQueueRef = myQueueRef;

      await myQueueRef.onDisconnect().remove();

      await myQueueRef.set({
        'uid': myUid,
        'name': user.name,
        'avatar': user.completeProfilePic ?? '',
        'badgeIconUrl': user.badge?.completeIconUrl,
        'badgeColor': user.badge?.color,
        'joinedAt': ServerValue.timestamp,
      });

      final responseRef =
          _db.child('challenges/queue_responses/${myQueueRef.key}');

      _queueSub = responseRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          if (data['matchId'] != null) {
            _queueSub?.cancel();
            _botTimer?.cancel();
            responseRef.remove();
            if (!completer.isCompleted) completer.complete(data['matchId'] as String);
          }
        }
      });
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(Exception(_firebaseErrorMessage(e)));
      }
    }

    return completer.future;

    return completer.future;
  }

  Future<String> _createBotMatch(int unitId, String courseTitle, String myUid,
      String? myName, String? myAvatar) async {
    final matchRef = _db.child('challenges/matches').push();
    final matchId = matchRef.key!;
    final challengeRepo = _ref.read(challengeRepositoryProvider);

    // Safety net: if app crashes during bot match, completely wipe the match!
    await matchRef.onDisconnect().remove();

    Map<String, dynamic> questionsData;
    try {
      questionsData = await challengeRepo.getQuestions(unitId);
    } catch (e) {
      // Fallback or handle error (e.g. production API not deployed yet)
      questionsData = {
        'questions': [
          {
            'id': 1,
            'question': 'أين تقع عاصمة الجزائر؟',
            'question_type': 'multiple_choices',
            'options': [
              {'id': 1, 'text': 'وهران', 'is_correct': 0},
              {'id': 2, 'text': 'الجزائر العاصمة', 'is_correct': 1},
              {'id': 3, 'text': 'قسنطينة', 'is_correct': 0},
              {'id': 4, 'text': 'عنابة', 'is_correct': 0},
            ]
          },
          {
            'id': 2,
            'question': 'هل 1 + 1 = 2؟',
            'question_type': 'true_or_false',
            'correct_answer': 1,
          }
        ]
      };
    }

    final questionsList = (questionsData['questions'] as List?) ?? [];

    final botNames = [
      'أحمد 🤓', 'سارة 📚', 'أمينة ⭐', 'ياسين 🚀', 'مريم ✨', 'عمر ⚔️', 
      'ليلى 🎨', 'حمزة 🦁', 'نور 🌙', 'إياد 🧠', 'ريان 🛡️', 'جنى 🌸'
    ];
    final botSeeds = ['Felix', 'Aneka', 'Caleb', 'Mimi', 'Jasper', 'Sasha', 'Bear', 'Coco'];
    final botName = botNames[Random().nextInt(botNames.length)];
    final botSeed = botSeeds[Random().nextInt(botSeeds.length)] + Random().nextInt(100).toString();
    
    final currentUser = _ref.read(userNotifierProvider).value;
    final userBadgeIcon = currentUser?.badge?.completeIconUrl;
    final userBadgeColor = currentUser?.badge?.color;

    await matchRef.set({
      'status': 'starting',
      'courseTitle': courseTitle,
      'unitId': unitId,
      'isBotMatch': true,
      'players': {
        myUid: {
          'uid': myUid,
          'name': myName ?? 'Guest',
          'avatar': myAvatar ?? '',
          'badgeIconUrl': userBadgeIcon,
          'badgeColor': userBadgeColor,
          'score': 0,
          'status': 'ready',
          'emoji': '',
        },
        'bot_${Random().nextInt(9999)}': {
          'uid': 'bot_123',
          'name': botName,
          'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=$botSeed',
          'badgeIconUrl': userBadgeIcon,
          'badgeColor': userBadgeColor,
          'score': 0,
          'status': 'ready',
          'emoji': '',
        },
      },
      'questions': questionsList,
      'currentQuestionIndex': 0,
      'createdAt': ServerValue.timestamp,
    }).timeout(const Duration(seconds: 3), onTimeout: () {
      throw Exception(
          'Firebase Realtime Database is not enabled or missing from config.');
    });
    return matchId;
  }
}
