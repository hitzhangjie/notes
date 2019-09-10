学习了Google的CodeReview指引，整理了其中一些比较有价值的点，分享给大家。

#  Google Code Review Guidelines

Google积累了很多最佳实践，涉及不同的开发语言、项目，[这些文档](https://google.github.io/eng-practices)，将Google工程师多年来积攒的一些最佳实践经验进行了总结并分享给众开发者。学习下这里的经验，我们在进行项目开发、开源协同的过程中，相信也可以从中受益。

Google目前公开的最佳实践相关文档，目前包括：

- [Google's Code Review Guidelines](https://google.github.io/eng-practices/review/)，Google代码review指引，包含以下两个系列的内容：
  - [The Code Reviewer's Guide](https://google.github.io/eng-practices/review/reviewer/)
  - [The Change Author's Guide](https://google.github.io/eng-practices/review/developer/)

这了涉及到Google内部使用的一些术语，先提下：

- CL: 代表changelist，表示一个提交到VCS的修改，或者等待review的修改，也有组织称之为change或patch；

- LGTM：代表Looks Good to ME，负责代码review的开发者对没有问题的CL进行的评论，表明代码看上去OK；

# [Code Review Developer Guide](https://google.github.io/eng-practices/review/)

## Introduction

Code Review（代码评审）指的是让第三者来阅读作者修改的代码，以发现代码中存在的问题。包括Google在内的很多公司会通能过Code Review的方式来保证代码和产品的质量。

前文已有提及，CR相关内容主要包括如下两个系列：

- [The Code Reviewer's Guide](https://google.github.io/eng-practices/review/reviewer/)
- [The Change Author's Guide](https://google.github.io/eng-practices/review/developer/)

这里先介绍下CR过程中应该做什么，或者CR的目标是什么。

## What Do Code Reviewers Look For?

Code review应该关注如下方面：

- Design：程序设计、架构设计是否设计合理
- Functionality：代码功能是否符合作者预期，代码行为是否用户友好
- Complexity：实现是否能简化，代码可读性是否良好，接口是否易用
- Tests：是否提供了正确、设计良好的自动化测试、单元测试
- Naming：变量名、类名、方法名等字面量的选择是否清晰、精炼
- Comments：是否编写了清晰的、有用的注释
- Style：代码风格是否符合规范
- Documentation：修改代码的同时，是否同步更新了相关文档

## Picking the Best Reviewers

一般，Code review之前，我们应该确定谁才是最好的、最合适的reviewer，这个reviewer应该**“有能力在比较合理的时间内对代码修改是否OK做出透彻、全面的判断”**。通常reviewer应该是编写被修改代码的owner，可能他是相关项目、相关源文件、相关代码行的创建者或者修改者，意味着我们发起Code review时，同一个项目可能需要涉及到多个reviewer进行Code review，让不同的、最合适的reviewer来review CL中涉及到的不同部分。

如果你心目中有一个合适的reviewer人选，但是这个人当前无法review，那么我们至少应该“@”或者“邮件抄送”该reviewer。

## In-Person Reviews

如果是结对编程的话，A写的代码B应该有能力进行代码review，那么直接找B进行review就可以了。

也可以进行现场评审（In-Person Reviews），一般是开发者介绍本次CL的主要内容、逻辑，其他reviewer对代码中年可能的问题、疑惑进行提问，本次CL的开发者进行解答，这种方式来发现CL中的问题也是常见的一种方式。较大型、急速上线的项目，这种方式团队内部用的还是比较多的。

# How to Do a Code Review

这里总计了一些Code review的建议，主要包括如下一些方面：

- [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)
- [What to Look For In a Code Review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- [Navigating a CL in Review](https://google.github.io/eng-practices/review/reviewer/navigate.html)
- [Speed of Code Reviews](https://google.github.io/eng-practices/review/reviewer/speed.html)
- [How to Write Code Review Comments](https://google.github.io/eng-practices/review/reviewer/comments.html)
- [Handling Pushback in Code Reviews](https://google.github.io/eng-practices/review/reviewer/pushback.html)

## [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)

代码review的主要目的就是为了保证代码质量、产品质量，另外Google的大部分代码都是内部公开的，一个统一的大仓库，通过代码review的方式来保证未来Google代码仓库的质量，Google设计的代码review工具以及一系列的review规范也都是为了这个目的。

为了实现这个目标，某些方面需要做一些权衡和取舍。

**首先，开发者必须能够持续优化**。如果开发者从来不对代码做优化，那么最终代码仓库一定会烂掉。如果一个reviewer进行代码review时很难快速投入，如不知道做了哪些变更，那么代码reviewer也会变得很沮丧。这样就不利于整体代码质量的提高。

**另外，代码reviewer有责任维护CL中涉及到的修改的质量**，要保证代码质量不会出现下降，时间久了也不至于烂尾。有的时候，某些团队可能由于时间有限、赶项目，代码质量就可能会出现一定的下降。

**还有，代码reviewer对自己review过的代码拥有owner权限，并要为代码后续出现的问题承担责任**。通过这种方式来进一步强化代码质量、一致性、可维护性。

基于上述考虑，Google制定了如下规定来作为Code review的内部标准：

> **In general, reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system being worked on, even if the CL isn’t perfect.**
>
> 一般，reviewers对CL进行review的时候，达到approved的条件是，CL本身可能不是完美的，但是它至少应保证不会导致系统整体代码质量的下降。

当然，也有一些限制，例如，如果一个CL添加了一个新特性，reviewer目前不想将其添加到系统中，尽管这个CL设计良好、编码良好，reviewer可能也会拒绝掉。

**值得一提的是，没有所谓的perfect code，只有better code**。

- 代码reviewers应该要求开发者对CL中每一行代码进行精雕细琢，然后再予以通过，这个要求并不过分。
- 或者，代码reviewers需要权衡下他们建议的“精雕细琢”的必要性和重要性。代码reviewers应该追求代码的持续优化，不能一味地追求完美。对于提升系统可维护性、可读性、可理解性的代码CL，reviewers应该尽快给出答复，不能因为一味追求完美主义将其搁置几天或者几周。

### Mentoring

Code review对于教授开发者一些新的东西，如编程语言、框架、软件设计原则等是非常重要的手段。进行代码review的时候添加一些comments有助于帮助开发者之间分享、学习一些新东西。分享知识也是持续改进代码质量的重要一环。

需要注意的是，如果comments内容是纯教育性的、分享性的，不是我们前面提到的强制性的必须应该做出优化的，那么最好在comments内容里面添加前缀“**Nit (Not Important)**”，这样的评论表示当前CL中不一定非要做出对应的优化、修改，只是一个建议、分享。

### Principles

- 技术本身、数据至上，以及一些个人偏好
- 代码风格的重要性，力求代码风格的一致，如果没有明确的代码风格，就用之前作者的风格
- 业内的代码风格、个人偏好，需要在二者之间适当平衡，reviewer也应该在代码风格上注意
- 如果没有明确的一些规定，reviewer可以要求CL作者遵循当前代码库中的一些惯用的做法

上述各条，均以不降低系统整体代码质量为度量标准。

### Resolving Conflicts

如果在代码review中出现了冲突的意见、观点，首先，开发者、reviewer应尽可能基于之前的代码、现在CL的代码达成一个共识，如果仍然达不成共识，或者很困难，最好能进行面对面沟通，或者将当前CL升级一下，供更多的人员进行讨论。可以考虑将技术Leader、项目经理拉进来一起讨论下。

这种面对面的方式比单纯地通过comments进行讨论要高效、友好地多，如果条件不允许只能通过comments方式进行，那么对于讨论的结果，应进行适当的总结，给出一个结论，方便之后的开发者能够了解之前的讨论结果。

目标就是，不要因为代码reviewer和CL作者之间达不成一致，就长时间将CL搁置。

## [What to Look For In a Code Review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)

结合前面提到的一些Code review标准，将Code review中应该关注的点进一步细化，主要以下内容。

### Design

Code review过程中最重要的事情就是看CL的整体设计是否合理，如CL中涉及到的各个部分的代码之间的接口、交互、衔接是否合理，是业务代码修改还是库的修改，和系统整体的集成是否合理，现在这个时间点添加这个新特性是否合理等等。

### Functionality

CL的功能是否符合开发者预期，开发者期望的这部分修改是否对用户友好，这里的用户包括产品用户（实际使用产品的人员）和开发者（将来可能使用这部分代码的人员，如CL修改的库代码）。

一般，我们希望开发者发起Code review之前，能够对CL进行充分的测试确保功能是符合预期的。但作为reviewer，还是要检查下边界条件的处理是否到位，比如并发中的data race问题，确保代码中不存在“可能”的bug。

reviewer有条件的话，也可以亲自验证下CL，比如CL是面向用户的产品（如UI改变），单纯看代码不能直觉地感受到做的调整，reviewer可以亲自patch这部分代码、编译构建、安装之后来体验下具体的改变。如果不是特别方便的话，也可以找相应的开发者提供一个demo演示下CL中涉及的变化。

另一个非常重要的点是，要检查CL中是否存在某种类型的并发问题，如deadlocks、race conditions等。这些问题也不是运行一下代码就能发现的，往往需要reviewer来细致地考虑下相关的操作，才能判定是否有引入该类问题。

### Complexity

CL是否过于复杂，这个需要对CL中的不同层次的内容进行逐一检查，如每行代码是否过于复杂，函数实现是否过于复杂，类实现是否过于复杂等。“过于复杂”意味着，不能被其他开发者快速吸收、理解。也有个笑话，开发者在调用、修改自己编写的代码的时候容易引入引入bug。这些都说明了复杂性的问题所在。



### Tests

### Naming

### Comments

### Style

### Documentation

### Every Line

### Context

### Good Things

### Summary

## [Navigating a CL in Review](https://google.github.io/eng-practices/review/reviewer/navigate.html)

## [Speed of Code Reviews](https://google.github.io/eng-practices/review/reviewer/speed.html)

## [How to Write Code Review Comments](https://google.github.io/eng-practices/review/reviewer/comments.html)

## [Handling Pushback in Code Reviews](https://google.github.io/eng-practices/review/reviewer/pushback.html)















