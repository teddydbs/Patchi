import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class CheckInViewModel {
    // MARK: - Step tracking

    enum Step: Int, CaseIterable {
        case mood
        case activities
        case emotions
        case details
        case reformulation
    }

    var currentStep: Step = .mood
    var isCompleted = false

    // MARK: - Data

    var moodScore: Int = 3
    var selectedActivities: [Activity] = []
    var selectedEmotions: [Emotion] = []
    var title: String = ""
    var note: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var photoData: Data?
    var isVoiceEntry: Bool = false
    var reformulationText: String = ""

    // MARK: - UI State

    var isLoadingPhoto = false
    var showReformulation = false

    // MARK: - Navigation

    var canGoNext: Bool {
        switch currentStep {
        case .mood: true
        case .activities: true  // Optionnel
        case .emotions: true    // Optionnel
        case .details: true     // Optionnel
        case .reformulation: true
        }
    }

    var isLastInputStep: Bool {
        currentStep == .details
    }

    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(Step.allCases.count)
    }

    func goNext() {
        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        Haptics.selection()

        if currentStep == .details {
            // Générer la reformulation avant d'afficher l'écran
            generateReformulation()
        }

        withAnimation(.easeInOut(duration: 0.4)) {
            currentStep = nextStep
        }
    }

    func goBack() {
        guard let prevStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStep = prevStep
        }
    }

    /// Termine le check-in immédiatement depuis n'importe quelle étape
    func finishEarly() {
        Haptics.selection()
        generateReformulation()
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStep = .reformulation
        }
    }

    // MARK: - Photo

    func loadPhoto() async {
        guard let item = selectedPhotoItem else { return }
        isLoadingPhoto = true
        defer { isLoadingPhoto = false }

        if let data = try? await item.loadTransferable(type: Data.self) {
            photoData = compressImage(data: data)
        }
    }

    /// Compresse et redimensionne une photo à 1200px max, JPEG quality 0.7
    private func compressImage(data: Data, maxDimension: CGFloat = 1200, quality: CGFloat = 0.7) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1.0)
        if scale < 1.0 {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            return resized.jpegData(compressionQuality: quality)
        }
        return image.jpegData(compressionQuality: quality) ?? data
    }

    // MARK: - Reformulation

    private func generateReformulation() {
        // Assembler le texte de l'utilisateur pour l'analyse
        var textParts: [String] = []

        if !title.isEmpty { textParts.append(title) }
        if !note.isEmpty { textParts.append(note) }

        // Ajouter les activités comme mots-clés
        for activity in selectedActivities {
            textParts.append(activity.displayName)
        }

        // Ajouter les émotions comme mots-clés
        for emotion in selectedEmotions {
            textParts.append(emotion.displayName)
        }

        let combinedText = textParts.joined(separator: " ")
        reformulationText = ReformulationService.shared.reformulate(combinedText)
    }

    // MARK: - Save

    func save(context: ModelContext) {
        guard !isCompleted else { return }
        Haptics.success()
        let checkIn = CheckIn(
            moodScore: moodScore,
            activities: selectedActivities,
            emotions: selectedEmotions,
            title: title.isEmpty ? nil : title,
            note: note.isEmpty ? nil : note,
            photoData: photoData,
            isVoiceEntry: isVoiceEntry
        )
        checkIn.reformulation = reformulationText

        context.insert(checkIn)
        isCompleted = true
    }

    // MARK: - Reset

    func reset() {
        currentStep = .mood
        moodScore = 3
        selectedActivities = []
        selectedEmotions = []
        title = ""
        note = ""
        selectedPhotoItem = nil
        photoData = nil
        isVoiceEntry = false
        reformulationText = ""
        isCompleted = false
        showReformulation = false
    }
}
