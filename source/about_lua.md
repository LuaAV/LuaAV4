## About Lua

### TL;DR

[Lua](http://www.lua.org) is *dynamic language*, comparable to JavaScript, Ruby, Python, Scheme, etc.

- *Fast*: Lua is faster than most dynamic languages; LuaJIT is comparable to C/C++
- Expressive and *easy to learn* -- you can pick up the basics in an hour or two
- One simple, powerful data structure
- Consistent rules of lexical scoping [(better than JavaScript...)](http://wtfjs.com/2010/02/15/hoisting)
- Benefits of functional programming (first-class, higher-order functions, closures, coroutines, prototype inheritance, etc.) without all the [silly parentheses](http://acronyms.thefreedictionary.com/Lots+of+Irritating+Single+Parentheses+%3A-))
- Garbage collection
- Small, *easy to embed*, with permissive [MIT license](http://www.opensource.org/licenses/mit-license.php); plus the LuaJIT FFI makes it even easier to interact with C libraries
- Portable (Windows, Linux, OSX, Android, iOS (no JIT), Xbox, RPi, and more... 

However:

- Fewer [libraries](http://luarocks.org/repositories/rocks/) than languages like Perl and Python
- No built-in support for multi-threading
- Arrays count from 1

### Dynamic

Lua is *dynamic language*, comparable to JavaScript, Ruby, Python, Scheme, etc.

> Dynamic programming language is a term used broadly in computer science to describe a class of high-level programming languages that execute at runtime many common behaviors that other languages might perform during compilation, if at all. [wikipedia](http://en.wikipedia.org/wiki/Dynamic_programming_language)

> For example, where a variable in C has a type bound to it which cannot change (static typing), a variable in Lua is just a name under which any type of value can be stored. (In a way, all variables in Lua behave like pointers.) More interestingly, any string of valid Lua code can be executed from within another script; opening the possibilty of generating new functions at run-time. Data structures can change size and layout during execution, and functions can be passed around just like any other object, all according to the vagaries of user input. (Some of these features are possible in C/C++ with a lot of clever coding, but the cleverer that code gets, the more it becomes like the virual machine of an interpreted langauge anyway…)

If dynamic languages are more flexible, adaptable, and extensible, why do people use static languages like C/C++/Java? 

Usually the argument goes that dynamism implies less efficient performance; however through the use of [just-in-time (JIT) compilation](http://en.wikipedia.org/wiki/Just-in-time_compilation), [LuaJIT](www.luajit.org) can approach and sometimes even exceed the speed of C/C++! It does this by recording ["traces"](http://en.wikipedia.org/wiki/Tracing_just-in-time_compilation): converting the most heavily used ("hot") code paths into optimized machine code, including complex traces running through different loops and function call chains. 

> Many of the recent innovations increasing the speed of JavaScript in modern web browsers use similar techniques as LuaJIT. [An interesting, though very technical, discussion here](http://lambda-the-ultimate.org/node/3851).


### Expressive

Lua began as a data-description language, and continues to benefit from a universal and flexible array/hash data structure. The syntax is largely procedural, however it supports fully functional programming features such as first-class functions, closures and coroutines, and lexically scoped upvalues (granting capabilities similar to [Scheme](http://en.wikipedia.org/wiki/Scheme_(programming_language))). It also supports various models of inheritence through a prototype inheritence chain (conceived in [Self](http://en.wikipedia.org/wiki/Self_(programming_language)) and also used in [JavaScript](http://en.wikipedia.org/wiki/JavaScript)). The runtime is also fully re-entrant.

### Documentation and Resources

#### Programming in Lua

This book is *excellent*. Get it from here:

[![PiL](http://www.lua.org/images/pil2.jpg)](http://www.amazon.com/exec/obidos/ASIN/8590379825/lua-docs-20)

Programming in Lua (second edition)   
by Roberto Ierusalimschy   
Lua.org, March 2006   
ISBN 85-903798-2-5 (also available as an e-book)

[Programming in Lua is also available in German, Korean, Chinese, and Japanese.](http://www.lua.org/docs.html#books)

#### The Lua 5.1 Reference Manual

Another excellent resource. Fortunately, [it is available online](http://www.lua.org/manual/5.1/)

[![Reference](http://www.lua.org/manual/5.1/cover.png)](http://www.amazon.com/exec/obidos/ASIN/8590379833/lua-indexmanual-20)

Lua 5.1 Reference Manual    
by R. Ierusalimschy, L. H. de Figueiredo, W. Celes   
Lua.org, August 2006   
ISBN 85-903798-3-3

In particular, [this is the URL that should be bookmarked](http://www.lua.org/manual/5.1/index.html#index).

#### The Lua and LuaJIT mailing lists

[Lua-l](http://vlists.pepperfish.net/cgi-bin/mailman/listinfo/lua-l-lists.lua.org), and 
[archive](http://lua-users.org/lists/lua-l/).

> Note that LuaJIT, and thus LuaAV, are based on Lua 5.1 syntax (with some Lua 5.2 features added), so some discussions on lua-l will not apply.

[LuaJIT mailing list](http://luajit.org/list.html), and [archive](http://www.freelists.org/archive/luajit/).

#### Other Lua guides

[Some tutorials on the Lua Wiki](http://lua-users.org/wiki/TutorialDirectory)

[This unofficial FAQ may also be useful](http://www.luafaq.org/)
