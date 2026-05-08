"use client"

import { useRef, useMemo } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Points, PointMaterial, Float } from '@react-three/drei'
import * as THREE from 'three'

function ParticleField() {
  const ref = useRef<any>(null)
  
  const particles = useMemo(() => {
    const p = new Float32Array(1500 * 3)
    for (let i = 0; i < 1500; i++) {
      p[i * 3] = (Math.random() - 0.5) * 12
      p[i * 3 + 1] = (Math.random() - 0.5) * 12
      p[i * 3 + 2] = (Math.random() - 0.5) * 12
    }
    return p
  }, [])

  useFrame((state, delta) => {
    if (ref.current) {
      ref.current.rotation.x -= delta / 15
      ref.current.rotation.y -= delta / 20
    }
  })

  return (
    <group rotation={[0, 0, Math.PI / 6]}>
      <Points ref={ref} positions={particles} stride={3} frustumCulled={false}>
        <PointMaterial
          transparent
          color="#10b981"
          size={0.04}
          sizeAttenuation={true}
          depthWrite={false}
          blending={THREE.NormalBlending}
          opacity={0.4}
        />
      </Points>
    </group>
  )
}

function GlowingOrb() {
  return (
    <Float speed={1.5} rotationIntensity={0.2} floatIntensity={0.5}>
      <mesh position={[3, 1, -3]}>
        <sphereGeometry args={[1.2, 32, 32]} />
        <meshStandardMaterial 
          emissive="#d97706" 
          emissiveIntensity={0.5} 
          color="#fef3c7" 
          transparent 
          opacity={0.15}
        />
      </mesh>
    </Float>
  )
}

export default function SpiritualScene() {
  return (
    <div className="fixed inset-0 -z-10 bg-[#FCFBF7]">
      <Canvas camera={{ position: [0, 0, 5], fov: 60 }}>
        <ambientLight intensity={0.8} />
        <pointLight position={[10, 10, 10]} intensity={0.5} color="#10b981" />
        <pointLight position={[-10, -10, -10]} intensity={0.2} color="#f59e0b" />
        <ParticleField />
        <GlowingOrb />
        <fog attach="fog" args={['#FCFBF7', 5, 12]} />
      </Canvas>
    </div>
  )
}
