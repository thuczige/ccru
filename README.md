# ccru – Check Changed Ruby (RuboCop-on-diff)

A tiny wrapper gem around RuboCop that only lints

- New files fully (files added in the current branch vs base)

- Modified files only on changed lines (diff hunks)

Works across Ruby/Rails versions by

- Shelling out to the rubocop CLI (avoids RuboCop API compatibility issues)

- Using conservative Ruby syntax and UTF-8 encoding headers

