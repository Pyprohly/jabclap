## JScript-Assisted Batch file Command line Argument Parser

Batch files are an effective means of creating custom commands, but due to the language’s limitations, handling arguments can be a difficult task. For this reason, command line interfaces in batch files are often implemented in strange ways that are vulnerable to breakage and prove to be unintuitive for the end user. This projects aims to solve these problems by bringing an intuitive argument handling system that allows you create robust and professional command line interfaces for your batch scripts while being easy to implement.

The JScript-Assisted Batch file Command line Argument Parser (JABCLAP) works by combining your batch project with an embedded JScript argument parsing script. The batch script calls the JScript parser and passes along the string of arguments given to the batch script. The JScript parser then processes the arguments, builds, and spits out the parsed arguments in an organised structure that your batch file can then use to prepare its environment for argument validation. No knowledge of JScript is required.

This system overcomes many of the drawbacks a pure batch parsing solution might have. Here are some of the benefits and features of JABCLAP at a glance:

* **Validate passed arguments with ease**—and issue detailed command line syntax error messages.
* **Resistant to breakage**—works in a variety of situations, or fails cleanly if it doesn’t.
* **Supports key-value named arguments**—you can easily handle duplicate keys too.
* **Supports named argument case sensitivity**—e.g., make option `-e` different  to `-E`.
* **Intersperse named arguments with positional arguments**—a courtesy of the parser.
* **Change the named arguments indicators**—make `+a` mean the opposite of `-a`.
* **A parser to suit your CLI style**—try out the UNIX parser which does flag bundling (`-abc` <==> `-a -b -c`).
* **Preserves the batch file’s parameter variables (`%1`, `%2`)**—still there when you need them.
* **Consistent**—simple to use and understand.

### Getting started

JABCLAP works as an embedded JScript. To get the argument parser working in your batch project you need to turn your batch file into a JScript-Batch hybrid. This can be done by using the code in one of two hybrid files in the `src` folder: `hybrid-js.bat` or `hybrid-wsf.bat`.

If your batch project is already a JScript hybrid then you’ll need to instead use the WSF hybrid to embed multiple JScript script files into a single script. One disadvantage you should be aware of when using the WSF hybrid as opposed to the JS hybrid is that some special characters will not be able to be used in the batch file portion, such as the escape character.

While the project can manually be pieced together from the files in the `src` folder, the easiest way to get a working template is to re-purpose one of the examples from the `build` directory.

```batchfile
C:\JABCLAP\samples>template.bat arg1 arg2 /switch
arg[#'switch']=1
arg[#;]=1
arg[#@]=3
arg[#a]=3
arg[#n]=1
arg[#p]=2
arg[#q]=1
arg[#]=2
arg['switch'1]=1
arg['switch']=1
arg[-'switch'1]=/
arg[-'switch']=/
arg[0]=template.bat
arg[1]=arg1
arg[2]=arg2
arg[;1]=switch
...
```

### Configuring the argument parser

Each parser has it’s own set of options. The available options and their effective equivalents are listed below.

```batchfile
:: CMD parser
set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_CASE_SENSITIVE=0"
set "JABCLAP_KEY_INDICATOR=/"
set "JABCLAP_PAIR_DELIMITER=:="
set "JABCLAP_END_OF_OPTIONS_MARKER="

:: UNIX parser
set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_CASE_SENSITIVE=1"
set "JABCLAP_FLAG_BUNDLING=1"
set "JABCLAP_KEY_INDICATOR=-"
set "JABCLAP_PAIR_DELIMITER== "
```

We’ll see how each option is used in the coming topics. For the purposes of this tutorial the CMD-style parser will always be used unless otherwise specified.

### Working with switches

By default, all named arguments are switches. You can test for switches by expanding <code>%arg['<i>key</i>']%</code>, where *`key`* is the key name being tested for. In the below script we are checking if `/?` was specified among the given arguments, so we test if the variable `arg['?']` is defined.

```batchfile
if defined arg['?'] (
	call :usage
	exit /b 0
)
```

Testing with `if defined` on <code>%arg['<i>key</i>']%</code> is sufficient for determining whether a switch is specified but you can always guarantee that the variable will expand to `1` and test against that value instead. To implement switches as aliases we can take advantage of this number using `set /a`.

In the example below `/a` is an alias of `/all`. If either is specified then a message will be shown.

```batchfile
set /a all=arg['v'] + arg['verbose']
if %all% geq 1 (
	echo Verbose output enabled
)
```

Undefined variables in `set /a` will default to a value of `0`. It is important that percent expansion isn’t used here, otherwise a `Missing operand.` error may occur.

### Working with key-value pairs

To specify that a named argument is a key-value pair it needs to be declared to the argument parser. This is done by setting the `JABCLAP_EXPECT_VALUE_FROM` environment variable to a space-separated list of expected key names prior to calling the argument parser.

```batchfile
@echo off
set "JABCLAP_EXPECT_VALUE_FROM=speed action"

...

set /a speed=10
if defined arg['speed'] set /a speed=arg['speed']

set "action=%arg['action']%"
if "%action%"=="" set "action=walk"

echo Do action %action% at speed %speed%
```

```
C:\>file.bat /action:jump /speed:20
Do action jump at speed 20
```

If the same named argument is specified multiple times then <code>%arg['<i>key</i>']%</code> will always expand the last value specified. The first value can still be accessed with <code>%arg['<i>key</i>'1]%</code>, and the second with <code>%arg['<i>key</i>'2]%</code>, and so on.

You can test the existence of the named argument as if it where a switch by using <code>%arg[?'<i>key</i>']%</code>. This may be useful for implementing optional values in key-value pairs.

### Working with positional arguments

A positional argument is accessed using <code>%arg[<i>n</i>]%</code>, where *n* is a number that represents an index starting from 1. The total count of positional arguments can be accessed with `%arg[#p]%`, or simply `%arg[#]%`, and it can be leveraged in a `for /l` loop to iterate the positional arguments.

```batchfile
for /l %%I in (1 1 %arg[#]%) do (
	echo Argument %%I is !arg[%%I]!
)
```

Empty strings are supported as positional arguments and a positional variable may expand to an empty string. It is thus unsafe to iterate the positional arguments by looping until a positional variable becomes empty or undefined. Always use the construct above to safely process all the positional arguments.

#### Restricting the number of positional arguments

The number stored in `%arg[#p]%` can be used to test whether the correct number of positional arguments have been specified. The demonstration below tests the value of `%arg[#p]%` and outputs an appropriate message if it is not 2 or 3.

```batchfile
:validate_arguments
setlocal
	if %arg[#p]% equ 1 echo Missing 1 required positional argument& exit /b 1
	if %arg[#p]% gtr 3 echo Takes from 2 to 3 positional arguments but %arg[#p]% were given& exit /b 1
endlocal
exit /b 0

:main
...

call :validate_arguments >&2 || exit /b 2
```

### Supporting duplicate named arguments

It sometimes make sense for a named argument to accept multiple values if the positional arguments are being used for something more important. As we’ve touched upon in a previous topic, key-value pairs can be accessed in a positional way by specifying an index after the key name, e.g., `%arg['e'2]%` for the value of the second instance of `/e`.

By knowing how many times `/e` was specified the same looping construct as with the positional arguments can be used to access the `/e` named arguments positionally. The number of times `/e` was specified is stored in `%arg[#'e']%`.

```batchfile
@echo off
set "JABCLAP_EXPECT_VALUE_FROM=e"

...

for /l %%I in (1 1 %arg[#'e']%) do (
	echo %%I: !arg['e'%%I]!
)
```

```
C:\>file.bat up down /e:foo /e:bar /e:baz
1: foo
2: bar
3: baz
```

### Handling unexpected named arguments

It’s a good idea to output an error message if the script was given an argument it wasn’t expecting.

<code>%arg[;<i>n</i>]%</code>, where *`n`* is the index, contains a list of the unique named arguments passed to the script. `%arg[#q]%` or `%arg[#;]%` expands to the length of this array. These variables can be used to detect when an unexpected named argument is used.

```batchfile
set "expected_keys=e t c"
for /l %%I in (1 1 %arg[#;]%) do (
	echo !arg[;%%I]!| findstr -bei "!expected_keys!" >nul || (
		>&2 echo Unexpected named argument '!arg[;%%I]!'
		exit /b 1
	)
)

echo etc.
```

```
C:\>file.bat /a
Unexpected named argument 'a'

C:\>file.bat /b
Unexpected named argument 'b'

C:\>file.bat /c
etc.

C:\>file.bat /e
etc.

```

If your batch file is prepared to handle case sensitive named arguments then use `-be` instead of `-bei` in `findstr`.

### Changing the named argument indicators

Switches in Windows commands are typically denoted by a forward slash (`/`), and the CMD-style JScript parser honours this convention. If we wanted to extend the set of named argument indicators to include a minus (`-`) or plus (`+`) we can simply add these characters to the `JABCLAP_KEY_INDICATOR` environment variable before calling the parser.

For any given named argument, the indicator that was used is stored in the <code>%arg[-'<i>key</i>']%</code> variable.

```batchfile
@echo off
set "JABCLAP_KEY_INDICATOR=/-+"

...

for /l %%I in (1 1 %arg[#;]%) do (
	for /f "delims=" %%K in ("!arg[;%%I]!") do (
		echo !arg[-'%%K']!%%K
	)
)
```

```
C:\>file.bat /n -d +e
/n
-d
+e
```

Named arguments can be disabled altogether (wherein all arguments become positional) by setting `JABCLAP_KEY_INDICATOR` to a space.

### Changing the named argument value delimiters

The CMD-style parser uses `:` or `=` as the default key-value delimiter. When the parser processes a key-value named argument it will attempt to split it into a key and a value by the first character that it comes across that is listed in the `JABCLAP_PAIR_DELIMITER` environment variable.

When a space character is used the parser will look at the next argument for a value to bind to.

```batchfile
@echo off
set "JABCLAP_EXPECT_VALUE_FROM=name id"
set "JABCLAP_KEY_INDICATOR=/-"
set "JABCLAP_PAIR_DELIMITER=:= "

...

for /l %%I in (1 1 %arg[#;]%) do (
	for /f "delims=" %%K in ("!arg[;%%I]!") do (
		echo %%K = !arg['%%K']!
	)
)
```

```
C:\>file.bat /name Bob -id=2348
name = Bob
id = 2348

```

### Supporting case sensitivity

If you’ve been coding in batch for any length of time you’d have noticed that variables are case insensitive, e.g., `%var%` expands to the same value as `%VAR%`. This makes all named arguments case insensitive by default (as an argument of `/key` and `/Key` will register as `%arg['key']%` and `%arg['Key']%` respectively, of which both expand to the same value). JABCLAP still gives you the ability to distinguish the exact casing that was used on the command line but you’ll have to carefully bake in some extra logic to support this.

Case sensitivity is switched on by default in the UNIX parser, but is disabled by default in the CMD parser. To enable case sensitivity, set the `JABCLAP_CASE_SENSITIVE` environment variable to `1` before calling the parser.

Switching on case sensitivity does two things:

* It prevents key-value named arguments from binding unless the key name casing exactly matches one of the keys specified in `JABCLAP_EXPECT_VALUE_FROM`.
* It gives access to the <code>%arg[\`<i>abc</i>\`]%</code> variables (`abc` is surrounded in backticks).

The <code>%arg[\`<i>abc</i>\`]%</code> variable stores the original casing of the key name of a named argument. It is index-able and will need to be indexed if you decide to implement two different switches of the same letter (or word) but different casing. The fact that ``%arg[`e`]%`` stores the casing of the latest used `/e`, for instance, will not be useful information because it could have shadowed a previously used `/E` or vice versa.

The following example distinguishes between `/e` and `/E`, and prints out a slightly different string format depending on which was used.

```batchfile
@echo off
set "JABCLAP_EXPECT_VALUE_FROM=e E"
set "JABCLAP_CASE_SENSITIVE=1"
set "JABCLAP_KEY_INDICATOR=/-"
set "JABCLAP_PAIR_DELIMITER=:= "

...

for /l %%I in (1 1 %arg[#'e']%) do (
	if "!arg[`e`%%I]!"=="e" (
		echo [!arg['e'%%I]!]
	) else if "!arg[`e`%%I]!"=="E" (
		echo __!arg['e'%%I]!__
	)
)
```

```
C:\>file -e=foo -E=bar -e=baz -E=qux -E=quux
[foo]
__bar__
[baz]
__qux__
__quux__

```

Notice that `JABCLAP_EXPECT_VALUE_FROM` contains both `e` and `E`. Specifying both here is important if case sensitivity is enabled.

### The end of options marker

In the UNIX command line it is a common convention for `--` to signify the end of options and that all arguments after this is to be treated as positional. This is supported by default in the JABCLAP UNIX-style parser. Similar functionality can be achieved in the CMD parser using `JABCLAP_END_OF_OPTIONS_MARKER`.

```batchfile
@echo off
set "JABCLAP_END_OF_OPTIONS_MARKER=//"

...

for /l %%I in (1 1 %arg[#]%) do (
	echo Argument %%I is !arg[%%I]!
)
```

```
C:\>file.bat /a /b // /c /d
Positional argument 1 is /c
Positional argument 2 is /d
```
