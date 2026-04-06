import SwiftUI

struct OnboardingStep {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let buttonText: LocalizedStringKey
}

struct OnboardingView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var currentStep = 0
    
    private let steps = [
        OnboardingStep(
            title: "onboarding_step1_title",
            description: "onboarding_step1_desc",
            buttonText: "onboarding_next_button"
        ),
        OnboardingStep(
            title: "onboarding_step2_title",
            description: "onboarding_step2_desc",
            buttonText: "onboarding_next_button"
        ),
        OnboardingStep(
            title: "onboarding_step3_title",
            description: "onboarding_step3_desc",
            buttonText: "onboarding_finish_button"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.onboardBack)
                .ignoresSafeArea()
            
            animationContainerView(for: currentStep)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 308)
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack(alignment: .top) {
                    VStack(spacing: 24) {
                        TabView(selection: $currentStep) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                OnboardingCard(step: steps[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 140)
                        
                        HStack(spacing: 8) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentStep ? Color.black : Color.gray.opacity(0.3))
                                    .frame(width: index == currentStep ? 24 : 4, height: 4)
                            }
                        }
                        Button(action: {
                            if currentStep < steps.count - 1 {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep += 1
                                }
                            } else {
                                coordinator.finishOnboarding()
                            }
                        }) {
                            Text(steps[currentStep].buttonText)
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.button)
                                .cornerRadius(28)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    .background(
                        Color.white
                            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                            .ignoresSafeArea()
                    )
                    .frame(height: 308)
                    
                    if currentStep == 1 {
                        Image(.appLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .offset(y: -30)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
        
        @ViewBuilder
        private func animationContainerView(for step: Int) -> some View {
            switch step {
            case 0:
                FirstStepCarouselView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 1:
                SecondStepStaticView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case 2:
                ThirdStepMapView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            default:
                EmptyView()
            }
        }
    }

struct OnboardingCard: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 16) {
            Text(step.title)
                .font(.onest(.bold, size: 24))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Text(step.description)
                .font(.onest(.regular, size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AppCoordinator())
}
