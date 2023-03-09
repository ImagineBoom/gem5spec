# Commit Message Format Recommendation

## Recommended Commit Message Format

**types**

- `feat`: The new feature you're adding to a particular application
- `fix`: A bug fix
- `style`: Feature and updates related to styling
- `refactor`: Refactoring a specific section of the codebase
- `test`: Everything related to testing
- `docs`: Everything related to documentation
- `chore`: Regular code maintenance. E.g., update repo ignore.
- `perf`: code improved in terms of processing performance
- `vendor`: update version for dependencies, packages.

**Scope**
(*TODO*: modify this scope example according to this project)
The scope could be anything specifying place of the commit change. For example `$location`, `$browser`, `$compile`, `$rootScope`, `ngHref`, `ngClick`, `ngView`, etc…

**Subject**

The subject contains succinct description of the change:

- use the imperative, present tense: “change” not “changed” nor “changes”
- don’t capitalize first letter
- no dot (.) at the end

**Body**

Just as in the **subject**, use the imperative, present tense: “change” not “changed” nor “changes”. The body should include the motivation for the change and contrast this with previous behavior.


**Footer**

The footer should contain any information about **BREAKING CHANGES** and is also the place to reference GitLab ISSUES that this commit **Closes**.

*Breaking Changes* should start with the word `BREAKING CHANGE:` with a space or two newlines. The rest of the commit message is then used for this.



**Command Template**

```bash
git commit -m'
<type>[optional scope]: subject (max length: 80 characters)
[add a blank line if there is a body]
[Optional Body] (max length: 80 characters)
[blank line]
[optional footer]
'
```



## Recommended Rules

- One commit for one thing. (Atomic)
- Use the imperative mood in the subject line. 
- Start message titles with a verb, e.g., fix something, update something, add something.
- Use the body to describe some details if you commit lots of changes.
- Every word counts! Keep subjects concise and meaningful.
- Separate the subject from the body with a blank line
- Your commit message should not contain any whitespace errors
- Remove unnecessary punctuation marks
- Do not end the subject line with a period
- Do not assume the reviewer know the original problem, add it to the footer.
- Do not think your code is self-explanatory
- Follow the commit convention defined by your team



**What is a Good Commit Message?**[1]

 (strongly recommended)

Atomic Commits, Short and Unambiguous, Active Voice, Detailed Enough, Formatting



**Reference**

[1] https://reflectoring.io/meaningful-commit-messages/
