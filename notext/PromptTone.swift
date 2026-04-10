import Foundation

enum PromptTone: String, CaseIterable, Identifiable {
    case direct = "Direct / Concis"
    case formal = "Professionnel / Formel"
    case creative = "Créatif"
    case developer = "Ingénieur Logiciel (Code)"
    case correction = "Correction Uniquement"
    case custom = "Personnalisé..."
    
    var id: String { self.rawValue }
    
    func buildPrompt(for text: String, customInstruction: String? = nil, targetLanguage: String? = nil) -> String {
        let constraint = "IMPORTANT: Tu ne dois donner aucune explication ni introduction. Retourne UNIQUEMENT le texte final prêt à être utilisé."
        let langConstraint = targetLanguage != nil ? " TRADUCTION OBLIGATOIRE : Le résultat final doit être intégralement en \(targetLanguage!)." : ""
        
        switch self {
        case .direct:
            return "Transforme le brouillon vocal suivant en un prompt optimisé. Sois bref, très direct et sans fioriture.\n\nBrouillon: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        case .formal:
            return "Reformule la note vocale suivante en un prompt clair, structuré et très professionnel.\n\nBrouillon: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        case .creative:
            return "Transforme cette note brouillonne en un prompt riche, engageant et très descriptif.\n\nBrouillon: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        case .developer:
            return "Reformule cette note en un prompt technique et structuré pour un Senior Software Engineer.\n\nBrouillon: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        case .correction:
            return "Agis comme un correcteur professionnel. Supprime les hésitations (euh, bah), corrige la grammaire et la ponctuation, mais GARDE le style original de l'utilisateur.\n\nTexte: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        case .custom:
            let instruction = customInstruction ?? "Reformule ce texte de manière optimale."
            return "\(instruction)\n\nTexte: \"\(text)\"\n\n\(constraint)\(langConstraint)"
        }
    }
}
