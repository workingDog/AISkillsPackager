#  SkillPackager


An experiment to learn about **AI skills and agents**, and packaging these into 
a package manifest with combined instructions ready for a AI model to use, for example using the REST API of Google Gemini.

## User interface

Basic 3 columns view.

-   list of skills for selections, with possible import
-   package view selection, details text, graph view and model packaging
-   package construction area

Functions

-   loads SKILL.md files into a library
-   select skills into a package
-   defines input/output mappings between selected skills
-   compiles and exports a package manifest with combined instructions


## Overview

Compose a set of skills ready for exporting as a manifest + combined instruction in JSON format.

1   Skill Library

-   store/import existing SKILL.md files
-   parse lightweight metadata
-   show them in a selectable list

2   Skill Composition

-   Let the user create a package made of selected skills plus explicit input/output mappings between them.

3   Packaging

Generate one portable package object:

-   selected skill contents
-   usage instructions for each skill
-   execution order
-   input/output mapping rules
-   final merged prompt/instruction text for ChatGPT, Gemini, ...

4   Target Exporters

Export that package in different forms:

-   API prompt bundle for OpenAI/Gemini
-   internal app format
-   zip/folder/catalogue manifest for reuse
