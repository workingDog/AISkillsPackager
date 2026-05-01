#  <#Title#>


loads SKILL.md files into a library
lets you select skills into a package
defines input/output mappings between selected skills
compiles and exports a package manifest with combined instructions






Starting Strategy

Treat this as 4 small systems instead of one big “skill composer”:

Skill Library
Store/import existing SKILL.md files, parse lightweight metadata, and show them in a selectable list.

Skill Composition
Let the user create a package made of selected skills plus explicit input/output mappings between them.

Package Compiler
Generate one portable package object:

selected skill contents
usage instructions for each skill
execution order
input/output mapping rules
final merged prompt/instruction text for ChatGPT, Gemini, or your own runtime
Target Exporters
Export that package in different forms:

API prompt bundle for OpenAI/Gemini
internal app format
zip/folder/catalogue manifest for reuse
A good first milestone is:

import local SKILL.md files
parse name/description/front matter
show multi-select list
create one SkillPackage
allow simple “output of A goes to input of B” mappings
export a single JSON manifest + combined instruction text


