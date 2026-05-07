//
//  SkillDefinition.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import SwiftUI

// the types in mapping the input and output ports, use in the markdown parser
enum SkillDataType: String, Codable, CaseIterable, Hashable, Sendable {
    case text
    case markdown
    case json
    case image
    case audio
    case number
    case boolean
    case any

    var color: Color {
        switch self {
            case .text: .blue
            case .markdown: .indigo
            case .json: .orange
            case .image: .pink
            case .audio: .purple
            case .number: .green
            case .boolean: .mint
            case .any: .gray
            }
    }

    func accepts(_ other: SkillDataType) -> Bool {
        self == .any || other == .any || self == other
    }
}

struct SkillPort: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var type: SkillDataType
    var isRequired: Bool

    init(id: UUID = UUID(), name: String, type: SkillDataType, isRequired: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.isRequired = isRequired
    }
}

@Observable
@MainActor
final class SkillDefinition: Identifiable, Hashable {
    let id: UUID
    var name: String
    var summary: String
    var markdown: String
    var declaredInputs: [SkillPort]
    var declaredOutputs: [SkillPort]
    var usageInstructions: String
    var sourceURL: URL?

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        markdown: String,
        declaredInputs: [SkillPort] = [],
        declaredOutputs: [SkillPort] = [],
        usageInstructions: String = "",
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.markdown = markdown
        self.declaredInputs = declaredInputs
        self.declaredOutputs = declaredOutputs
        self.usageInstructions = usageInstructions
        self.sourceURL = sourceURL
    }

    static func == (lhs: SkillDefinition, rhs: SkillDefinition) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let samples: [SkillDefinition] = [
        SkillDefinition(
            name: "Web Research",
            summary: "Fetches fresh information from the web.",
            markdown: "# Web Research",
            declaredInputs: [
                SkillPort(name: "query", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "findings", type: .markdown, isRequired: true)
            ],
            usageInstructions: "Use when current external information is needed."
        ),
        SkillDefinition(
            name: "Outline Writer",
            summary: "Turns findings into a structured outline.",
            markdown: "# Outline Writer",
            declaredInputs: [
                SkillPort(name: "findings", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "outline", type: .markdown, isRequired: true)
            ],
            usageInstructions: "Use after research."
        ),
        SkillDefinition(
            name: "Words tester",
            summary: "Check the list of words",
            markdown: "# Words tester",
            declaredInputs: [
                SkillPort(name: "outline", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "query", type: .text, isRequired: true)
            ],
            usageInstructions: "Use whenever"
        ),
        SkillDefinition(
            name: "Image Generator",
            summary: "Creates a visual asset from a prompt.",
            markdown: "# Image Generator",
            declaredInputs: [
                SkillPort(name: "prompt", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "image", type: .image, isRequired: true)
            ],
            usageInstructions: "Use when a bitmap image is needed."
        ),
        SkillDefinition(
            name: "Test skill",
            summary: "Test a prompt.",
            markdown: """
                ---
                name: canvas-design
                description: Create beautiful visual art in .png and .pdf documents using design philosophy. You should use this skill when the user asks to create a poster, piece of art, design, or other static piece. Create original visual designs, never copying existing artists' work to avoid copyright violations.
                license: Complete terms in LICENSE.txt
                ---

                These are instructions for creating design philosophies - aesthetic movements that are then EXPRESSED VISUALLY. Output only .md files, .pdf files, and .png files.

                Complete this in two steps:
                1. Design Philosophy Creation (.md file)
                2. Express by creating it on a canvas (.pdf file or .png file)

                First, undertake this task:

                ## DESIGN PHILOSOPHY CREATION

                To begin, create a VISUAL PHILOSOPHY (not layouts or templates) that will be interpreted through:
                - Form, space, color, composition
                - Images, graphics, shapes, patterns
                - Minimal text as visual accent

                ### THE CRITICAL UNDERSTANDING
                - What is received: Some subtle input or instructions by the user that should be taken into account, but used as a foundation; it should not constrain creative freedom.
                - What is created: A design philosophy/aesthetic movement.
                - What happens next: Then, the same version receives the philosophy and EXPRESSES IT VISUALLY - creating artifacts that are 90% visual design, 10% essential text.

                Consider this approach:
                - Write a manifesto for an art movement
                - The next phase involves making the artwork

                The philosophy must emphasize: Visual expression. Spatial communication. Artistic interpretation. Minimal words.

                ### HOW TO GENERATE A VISUAL PHILOSOPHY

                **Name the movement** (1-2 words): "Brutalist Joy" / "Chromatic Silence" / "Metabolist Dreams"

                **Articulate the philosophy** (4-6 paragraphs - concise but complete):

                To capture the VISUAL essence, express how the philosophy manifests through:
                - Space and form
                - Color and material
                - Scale and rhythm
                - Composition and balance
                - Visual hierarchy

                **CRITICAL GUIDELINES:**
                - **Avoid redundancy**: Each design aspect should be mentioned once. Avoid repeating points about color theory, spatial relationships, or typographic principles unless adding new depth.
                - **Emphasize craftsmanship REPEATEDLY**: The philosophy MUST stress multiple times that the final work should appear as though it took countless hours to create, was labored over with care, and comes from someone at the absolute top of their field. This framing is essential - repeat phrases like "meticulously crafted," "the product of deep expertise," "painstaking attention," "master-level execution."
                - **Leave creative space**: Remain specific about the aesthetic direction, but concise enough that the next Claude has room to make interpretive choices also at a extremely high level of craftmanship.

                The philosophy must guide the next version to express ideas VISUALLY, not through text. Information lives in design, not paragraphs.

                ### PHILOSOPHY EXAMPLES

                **"Concrete Poetry"**
                Philosophy: Communication through monumental form and bold geometry.
                Visual expression: Massive color blocks, sculptural typography (huge single words, tiny labels), Brutalist spatial divisions, Polish poster energy meets Le Corbusier. Ideas expressed through visual weight and spatial tension, not explanation. Text as rare, powerful gesture - never paragraphs, only essential words integrated into the visual architecture. Every element placed with the precision of a master craftsman.

                **"Chromatic Language"**
                Philosophy: Color as the primary information system.
                Visual expression: Geometric precision where color zones create meaning. Typography minimal - small sans-serif labels letting chromatic fields communicate. Think Josef Albers' interaction meets data visualization. Information encoded spatially and chromatically. Words only to anchor what color already shows. The result of painstaking chromatic calibration.

                **"Analog Meditation"**
                Philosophy: Quiet visual contemplation through texture and breathing room.
                Visual expression: Paper grain, ink bleeds, vast negative space. Photography and illustration dominate. Typography whispered (small, restrained, serving the visual). Japanese photobook aesthetic. Images breathe across pages. Text appears sparingly - short phrases, never explanatory blocks. Each composition balanced with the care of a meditation practice.

                **"Organic Systems"**
                Philosophy: Natural clustering and modular growth patterns.
                Visual expression: Rounded forms, organic arrangements, color from nature through architecture. Information shown through visual diagrams, spatial relationships, iconography. Text only for key labels floating in space. The composition tells the story through expert spatial orchestration.

                **"Geometric Silence"**
                Philosophy: Pure order and restraint.
                Visual expression: Grid-based precision, bold photography or stark graphics, dramatic negative space. Typography precise but minimal - small essential text, large quiet zones. Swiss formalism meets Brutalist material honesty. Structure communicates, not words. Every alignment the work of countless refinements.

                *These are condensed examples. The actual design philosophy should be 4-6 substantial paragraphs.*

                ### ESSENTIAL PRINCIPLES
                - **VISUAL PHILOSOPHY**: Create an aesthetic worldview to be expressed through design
                - **MINIMAL TEXT**: Always emphasize that text is sparse, essential-only, integrated as visual element - never lengthy
                - **SPATIAL EXPRESSION**: Ideas communicate through space, form, color, composition - not paragraphs
                - **ARTISTIC FREEDOM**: The next Claude interprets the philosophy visually - provide creative room
                - **PURE DESIGN**: This is about making ART OBJECTS, not documents with decoration
                - **EXPERT CRAFTSMANSHIP**: Repeatedly emphasize the final work must look meticulously crafted, labored over with care, the product of countless hours by someone at the top of their field

                **The design philosophy should be 4-6 paragraphs long.** Fill it with poetic design philosophy that brings together the core vision. Avoid repeating the same points. Keep the design philosophy generic without mentioning the intention of the art, as if it can be used wherever. Output the design philosophy as a .md file.

                ---

                ## DEDUCING THE SUBTLE REFERENCE

                **CRITICAL STEP**: Before creating the canvas, identify the subtle conceptual thread from the original request.

                **THE ESSENTIAL PRINCIPLE**:
                The topic is a **subtle, niche reference embedded within the art itself** - not always literal, always sophisticated. Someone familiar with the subject should feel it intuitively, while others simply experience a masterful abstract composition. The design philosophy provides the aesthetic language. The deduced topic provides the soul - the quiet conceptual DNA woven invisibly into form, color, and composition.

                This is **VERY IMPORTANT**: The reference must be refined so it enhances the work's depth without announcing itself. Think like a jazz musician quoting another song - only those who know will catch it, but everyone appreciates the music.

                ---

                ## CANVAS CREATION

                With both the philosophy and the conceptual framework established, express it on a canvas. Take a moment to gather thoughts and clear the mind. Use the design philosophy created and the instructions below to craft a masterpiece, embodying all aspects of the philosophy with expert craftsmanship.

                **IMPORTANT**: For any type of content, even if the user requests something for a movie/game/book, the approach should still be sophisticated. Never lose sight of the idea that this should be art, not something that's cartoony or amateur.

                To create museum or magazine quality work, use the design philosophy as the foundation. Create one single page, highly visual, design-forward PDF or PNG output (unless asked for more pages). Generally use repeating patterns and perfect shapes. Treat the abstract philosophical design as if it were a scientific bible, borrowing the visual language of systematic observation—dense accumulation of marks, repeated elements, or layered patterns that build meaning through patient repetition and reward sustained viewing. Add sparse, clinical typography and systematic reference markers that suggest this could be a diagram from an imaginary discipline, treating the invisible subject with the same reverence typically reserved for documenting observable phenomena. Anchor the piece with simple phrase(s) or details positioned subtly, using a limited color palette that feels intentional and cohesive. Embrace the paradox of using analytical visual language to express ideas about human experience: the result should feel like an artifact that proves something ephemeral can be studied, mapped, and understood through careful attention. This is true art. 

                **Text as a contextual element**: Text is always minimal and visual-first, but let context guide whether that means whisper-quiet labels or bold typographic gestures. A punk venue poster might have larger, more aggressive type than a minimalist ceramics studio identity. Most of the time, font should be thin. All use of fonts must be design-forward and prioritize visual communication. Regardless of text scale, nothing falls off the page and nothing overlaps. Every element must be contained within the canvas boundaries with proper margins. Check carefully that all text, graphics, and visual elements have breathing room and clear separation. This is non-negotiable for professional execution. **IMPORTANT: Use different fonts if writing text. Search the `./canvas-fonts` directory. Regardless of approach, sophistication is non-negotiable.**

                Download and use whatever fonts are needed to make this a reality. Get creative by making the typography actually part of the art itself -- if the art is abstract, bring the font onto the canvas, not typeset digitally.

                To push boundaries, follow design instinct/intuition while using the philosophy as a guiding principle. Embrace ultimate design freedom and choice. Push aesthetics and design to the frontier. 

                **CRITICAL**: To achieve human-crafted quality (not AI-generated), create work that looks like it took countless hours. Make it appear as though someone at the absolute top of their field labored over every detail with painstaking care. Ensure the composition, spacing, color choices, typography - everything screams expert-level craftsmanship. Double-check that nothing overlaps, formatting is flawless, every detail perfect. Create something that could be shown to people to prove expertise and rank as undeniably impressive.

                Output the final result as a single, downloadable .pdf or .png file, alongside the design philosophy used as a .md file.

                ---

                ## FINAL STEP

                **IMPORTANT**: The user ALREADY said "It isn't perfect enough. It must be pristine, a masterpiece if craftsmanship, as if it were about to be displayed in a museum."

                **CRITICAL**: To refine the work, avoid adding more graphics; instead refine what has been created and make it extremely crisp, respecting the design philosophy and the principles of minimalism entirely. Rather than adding a fun filter or refactoring a font, consider how to make the existing composition more cohesive with the art. If the instinct is to call a new function or draw a new shape, STOP and instead ask: "How can I make what's already here more of a piece of art?"

                Take a second pass. Go back to the code and refine/polish further to make this a philosophically designed masterpiece.

                ## MULTI-PAGE OPTION

                To create additional pages when requested, create more creative pages along the same lines as the design philosophy but distinctly different as well. Bundle those pages in the same .pdf or many .pngs. Treat the first page as just a single page in a whole coffee table book waiting to be filled. Make the next pages unique twists and memories of the original. Have them almost tell a story in a very tasteful way. Exercise full creative freedom.
                """,
            declaredInputs: [
                SkillPort(name: "prompt", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "test", type: .image, isRequired: true)
            ],
            usageInstructions: "Use when nothing else works"
        ),
        // from https://github.com/twostraws/SwiftAgents/blob/main/AGENTS.md
        SkillDefinition(
            name: "SwiftUI coding",
            summary: "Asking about Swift and SwiftUI code",
            markdown: """
                # Agent guide for Swift and SwiftUI

                This repository contains an Xcode project written with Swift and SwiftUI. Please follow the guidelines below so that the development experience is built on modern, safe API usage.


                ## Role

                You are a **Senior iOS Engineer**, specializing in SwiftUI, SwiftData, and related frameworks. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.


                ## Core instructions

                - Target iOS 26.0 or later. (Yes, it definitely exists.)
                - Swift 6.2 or later, using modern Swift concurrency. Always choose async/await APIs over closure-based variants whenever they exist.
                - SwiftUI backed up by `@Observable` classes for shared data.
                - Do not introduce third-party frameworks without asking first.
                - Avoid UIKit unless requested.


                ## Swift instructions

                - `@Observable` classes must be marked `@MainActor` unless the project has Main Actor default actor isolation. Flag any `@Observable` class missing this annotation.
                - All shared data should use `@Observable` classes with `@State` (for ownership) and `@Bindable` / `@Environment` (for passing).
                - Strongly prefer not to use `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject` unless they are unavoidable, or if they exist in legacy/integration contexts when changing architecture would be complicated.
                - Assume strict Swift concurrency rules are being applied.
                - Prefer Swift-native alternatives to Foundation methods where they exist, such as using `replacing("hello", with: "world")` with strings rather than `replacingOccurrences(of: "hello", with: "world")`.
                - Prefer modern Foundation API, for example `URL.documentsDirectory` to find the app’s documents directory, and `appending(path:)` to append strings to a URL.
                - Never use C-style number formatting such as `Text(String(format: "%.2f", abs(myNumber)))`; always use `Text(abs(change), format: .number.precision(.fractionLength(2)))` instead.
                - Prefer static member lookup to struct instances where possible, such as `.circle` rather than `Circle()`, and `.borderedProminent` rather than `BorderedProminentButtonStyle()`.
                - Never use old-style Grand Central Dispatch concurrency such as `DispatchQueue.main.async()`. If behavior like this is needed, always use modern Swift concurrency.
                - Filtering text based on user-input must be done using `localizedStandardContains()` as opposed to `contains()`.
                - Avoid force unwraps and force `try` unless it is unrecoverable.
                - Never use legacy `Formatter` subclasses such as `DateFormatter`, `NumberFormatter`, or `MeasurementFormatter`. Always use the modern `FormatStyle` API instead. For example, to format a date, use `myDate.formatted(date: .abbreviated, time: .shortened)`. To parse a date from a string, use `Date(inputString, strategy: .iso8601)`. For numbers, use `myNumber.formatted(.number)` or custom format styles.

                ## SwiftUI instructions

                - Always use `foregroundStyle()` instead of `foregroundColor()`.
                - Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.
                - Always use the `Tab` API instead of `tabItem()`.
                - Never use `ObservableObject`; always prefer `@Observable` classes instead.
                - Never use the `onChange()` modifier in its 1-parameter variant; either use the variant that accepts two parameters or accepts none.
                - Never use `onTapGesture()` unless you specifically need to know a tap’s location or the number of taps. All other usages should use `Button`.
                - Never use `Task.sleep(nanoseconds:)`; always use `Task.sleep(for:)` instead.
                - Never use `UIScreen.main.bounds` to read the size of the available space.
                - Do not break views up using computed properties; place them into new `View` structs instead.
                - Do not force specific font sizes; prefer using Dynamic Type instead.
                - Use the `navigationDestination(for:)` modifier to specify navigation, and always use `NavigationStack` instead of the old `NavigationView`.
                - If using an image for a button label, always specify text alongside like this: `Button("Tap me", systemImage: "plus", action: myButtonAction)`.
                - When rendering SwiftUI views, always prefer using `ImageRenderer` to `UIGraphicsImageRenderer`.
                - Don’t apply the `fontWeight()` modifier unless there is good reason. If you want to make some text bold, always use `bold()` instead of `fontWeight(.bold)`.
                - Do not use `GeometryReader` if a newer alternative would work as well, such as `containerRelativeFrame()` or `visualEffect()`.
                - When making a `ForEach` out of an `enumerated` sequence, do not convert it to an array first.
                - When hiding scroll view indicators, use the `.scrollIndicators(.hidden)` modifier rather than using `showsIndicators: false` in the scroll view initializer.
                - Use the newest ScrollView APIs for item scrolling and positioning (e.g. `ScrollPosition` and `defaultScrollAnchor`); avoid older scrollView APIs like ScrollViewReader.
                - Place view logic into view models or similar, so it can be tested.
                - Avoid `AnyView` unless it is absolutely required.
                - Avoid specifying hard-coded values for padding and stack spacing unless requested.
                - Avoid using UIKit colors in SwiftUI code.


                ## SwiftData instructions

                If SwiftData is configured to use CloudKit:

                - Never use `@Attribute(.unique)`.
                - Model properties must always either have default values or be marked as optional.
                - All relationships must be marked optional.


                ## Project structure

                - Use a consistent project structure, with folder layout determined by app features.
                - Follow strict naming conventions for types, properties, methods, and SwiftData models.
                - Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file.
                - Write unit tests for core application logic.
                - Only write UI tests if unit tests are not possible.
                - Add code comments and documentation comments as needed.
                - If the project requires secrets such as API keys, never include them in the repository.
                - If the project uses Localizable.xcstrings, prefer to add user-facing strings using symbol keys (e.g. helloWorld) in the string catalog with `extractionState` set to "manual", accessing them via generated symbols such as  `Text(.helloWorld)`. Offer to translate new keys into all languages supported by the project.


                ## PR instructions

                - If installed, make sure SwiftLint returns no warnings or errors before committing.


                ## Xcode MCP

                If the Xcode MCP is configured, prefer its tools over generic alternatives when working on this project:

                - `DocumentationSearch` — verify API availability and correct usage before writing code
                - `BuildProject` — build the project after making changes to confirm compilation succeeds
                - `GetBuildLog` — inspect build errors and warnings
                - `RenderPreview` — visually verify SwiftUI views using Xcode Previews
                - `XcodeListNavigatorIssues` — check for issues visible in the Xcode Issue Navigator
                - `ExecuteSnippet` — test a code snippet in the context of a source file
                - `XcodeRead`, `XcodeWrite`, `XcodeUpdate` — prefer these over generic file tools when working with Xcode project files
                """
            ,
            declaredInputs: [
                SkillPort(name: "prompt", type: .text, isRequired: true)
            ],
            declaredOutputs: [
                SkillPort(name: "SwiftUI", type: .image, isRequired: true)
            ],
            usageInstructions: "Use when asking about SwiftUI code."
        )
    ]
}
