//
//  OrbView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

public struct OrbConfiguration {
    public init(
        backgroundColors: [Color] = [.green, .blue, .pink],
        glowColor: Color = .white,
        coreGlowIntensity: Double = 1.0,
        showBackground: Bool = true,
        showWavyBlobs: Bool = true,
        showParticles: Bool = true,
        showGlowEffects: Bool = true,
        showShadow: Bool = true,
        speed: Double = 60
    ) {
        self.backgroundColors = backgroundColors
        self.glowColor = glowColor
        self.showBackground = showBackground
        self.showWavyBlobs = showWavyBlobs
        self.showParticles = showParticles
        self.showGlowEffects = showGlowEffects
        self.showShadow = showShadow
        self.coreGlowIntensity = coreGlowIntensity
        self.speed = speed
    }
    
    var glowColor: Color
    var backgroundColors: [Color]

    var showBackground: Bool
    var showWavyBlobs: Bool
    var showParticles: Bool
    var showGlowEffects: Bool
    var showShadow: Bool

    var coreGlowIntensity: Double
    var speed: Double
}

public struct OrbView: View {
    let configuration: OrbConfiguration
    
    // Cache computed properties
    private let glowColor: Color
    private let orbElementsSpeed: Double
    
    public init(configuration: OrbConfiguration = OrbConfiguration()) {
        self.configuration = configuration
        self.glowColor = configuration.glowColor
        self.orbElementsSpeed = configuration.speed
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                if configuration.showBackground {
                    background
                }
                
                // Combine glow effects into single layer
                glowEffectsLayer(size: size)
                    .drawingGroup() // Use Metal rendering
                
                if configuration.showWavyBlobs {
                    wavyBlobsLayer(size: size)
                        .drawingGroup()
                }
                
                if configuration.showParticles {
                    particleView
                        .frame(maxWidth: size, maxHeight: size)
                }
            }
            .overlay {
                orbOutlineLayer
                    .drawingGroup()
            }
            .mask {
                Circle()
            }
            .aspectRatio(1, contentMode: .fit)
            .modifier(
                RealisticShadowModifier(
                    colors: configuration.showShadow ? configuration.backgroundColors : [.clear],
                    radius: size * 0.08
                )
            )
        }
    }
    
    // Extract layers into separate views for better performance
    private func glowEffectsLayer(size: CGFloat) -> some View {
        ZStack {
            BackgroundView(color: glowColor,
                         rotationSpeed: orbElementsSpeed * 0.75,
                         direction: .counterClockwise)
                .padding(size * 0.03)
                .blur(radius: size * 0.06)
                .rotationEffect(.degrees(180))
                .blendMode(.destinationOver)
            
            if configuration.showGlowEffects {
                coreGlowEffects(size: size)
            }
        }
    }
    
    var background: some View {
        LinearGradient(colors: configuration.backgroundColors,
                       startPoint: .bottom,
                       endPoint: .top)
    }

    var orbOutlineColor: LinearGradient {
        LinearGradient(colors: [.white, .clear],
                       startPoint: .bottom,
                       endPoint: .top)
    }
    
    var particleView: some View {
        // Added multiple particle effects since the blurring amounts are different
        ZStack {
            ParticlesView(
                color: .white,
                speedRange: 10...20,
                sizeRange: 0.5...1,
                particleCount: 10,
                opacityRange: 0...0.3
            )
            .blur(radius: 1)
            
            ParticlesView(
                color: .white,
                speedRange: 20...30,
                sizeRange: 0.2...1,
                particleCount: 10,
                opacityRange: 0.3...0.8
            )
        }
        .blendMode(.plusLighter)
    }

    var wavyBlob: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            BackgroundView(color: .white.opacity(0.75),
                           rotationSpeed: orbElementsSpeed * 1.5,
                           direction: .clockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / orbElementsSpeed * 1.75)
                        .frame(maxWidth: size * 1.875)
                        .offset(x: 0, y: size * 0.31)
                }
                .blur(radius: 1)
                .blendMode(.plusLighter)
        }
    }

    var wavyBlobTwo: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            BackgroundView(color: .white,
                           rotationSpeed: orbElementsSpeed * 0.75,
                           direction: .counterClockwise)
                .mask {
                    WavyBlobView(color: .white, loopDuration: 60 / orbElementsSpeed * 2.25)
                        .frame(maxWidth: size * 1.25)
                        .rotationEffect(.degrees(90))
                        .offset(x: 0, y: size * -0.31)
                }
                .opacity(0.5)
                .blur(radius: 1)
                .blendMode(.plusLighter)
        }
    }
}

#Preview {
    let config = OrbConfiguration()
    OrbView(configuration: config)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 120)
}
