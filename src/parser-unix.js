
Array.prototype.indexOf = function(needle) {
	for (var i = 0; i < this.length; i++) {
		if (this[i] === needle) {
			return i
		}
	}
	return -1
}

function isNamedArgument(str) {
	if (str.length < 2) { return false }
	return !!~pairIndicator.indexOf(str.charAt(0))
}

function _newNamedArgument() {
	nC++

	if (seen.hasOwnProperty(lkey)) {
		seen[lkey]++
	} else {
		seen[lkey] = 1
		output += '[;' + ++qC + ']=' + key + '\n'
	}

	output += ("[#'" + key + "']=" + seen[lkey]
			+ "\n[?'" + key + "']=1"
			+ "\n[?'" + key + "'" + seen[lkey] + ']=1'
			+ "\n[-'" + key + "']=" + ind
			+ "\n[-'" + key + "'" + seen[lkey] + ']=' + ind
			+ '\n')

	if (caseSensitive) {
		output += ('[`' + lkey + '`' + seen[lkey] + ']=' + key
				+ '\n[`' + lkey + '`]=' + key + '\n')
	}
}

RegExp.escapePattern = /[-\/\\^$*+?.()|[\]{}]/g
RegExp.escape = function(s) {
	return s.replace(RegExp.escapePattern, '\\$&')
}

var args = WScript.Arguments
var wsh = new ActiveXObject('WScript.Shell')

var pairsExpected = wsh.Environment('Process')('JABCLAP_EXPECT_VALUE_FROM')
var caseSensitive = parseInt(wsh.Environment('Process')('JABCLAP_CASE_SENSITIVE'))
if (isNaN(caseSensitive)) { caseSensitive = true }
var bundleFlags = parseInt(wsh.Environment('Process')('JABCLAP_FLAG_BUNDLING'))
if (isNaN(bundleFlags)) { bundleFlags = true }
var pairIndicator = wsh.Environment('Process')('JABCLAP_KEY_INDICATOR') || '-'
var pairDelimiter = wsh.Environment('Process')('JABCLAP_PAIR_DELIMITER') || '= '

var expectFrom = (caseSensitive ? pairsExpected : pairsExpected.toLowerCase()).split(' ')
var endOfOptions = /^\s+$/.test(pairIndicator)
var delimRegex = new RegExp('[' + RegExp.escape(pairDelimiter) + ']')

var output = ''
var seen = {}
var expectingKeyValue = false
var pC = 0, nC = 0, qC = 0
var allArgs = [], allPositionalArgs = []
for (i = 0; i < args.length; i++) {
	var arg = args.Item(i)
	allArgs.push(arg)

	output += '[@' + (i + 1) + ']=' + arg + '\n'

	if (arg === '--') {
		endOfOptions = true
		continue
	}

	if (expectingKeyValue) {
		expectingKeyValue = false
		if (!isNamedArgument(arg)) {
			output += ("[-'" + key + "']=" + ind
					+ "\n[-'" + key + "'" + seen[lkey] + ']=' + ind
					+ "\n['" + key + "']=" + arg
					+ "\n['" + key + "'" + seen[lkey] + ']=' + arg
					+ '\n')
			continue
		}
	}

	if (!endOfOptions && isNamedArgument(arg)) {
		var ind = arg.charAt(0)
		var akey = arg.slice(1)
		var d = arg.search(delimRegex)
		var sep = arg.charAt(d)
		var key = ~d ? arg.slice(1, d) : akey
		var lkey = key.toLowerCase()
		var value = ~d ? akey.slice(d) : ''

		if (~expectFrom.indexOf(caseSensitive ? key : lkey)) {
			// It's a key-value pair

			_newNamedArgument()
			if (value) {
				output += ("['" + key + "']=" + value
						+ "\n['" + key + "'" + seen[lkey] + ']=' + value
						+ '\n')
			} else {
				output += "['" + key + "']=\n"
				if (~pairDelimiter.indexOf(' ')) {
					expectingKeyValue = true
				}
			}
		} else if (bundleFlags && (/[a-z0-9]/i.test(arg.charAt(1)))) {
			// It's a flag bundle. Expand it

			for (var k = 0; k < akey.length; k++) {
				key = akey.charAt(k)
				lkey = key.toLowerCase()

				// Stop processing flags at the first non-alphanumeric flag
				if (/[^a-z0-9]/i.test(key)) { break }

				_newNamedArgument()

				if (~expectFrom.indexOf(key)) {
					value = akey.slice(k + 1)
					if (value) {
						output += ("['" + key + "']=" + value
								+ "\n['" + key + "'" + seen[lkey] + ']=' + value
								+ '\n')
					} else {
						if (~pairDelimiter.indexOf(' ')) {
							expectingKeyValue = true
						}
						output += "['" + key + "']=" + '\n'
					}
					break
				} else {
					output += ("['" + key + "']=1"
							+ "\n['" + key + "'" + seen[lkey] + ']=1'
							+ '\n')
				}
			}
		} else {
			// It's a switch

			_newNamedArgument()

			output += ("['" + akey + "']=1"
					+ "\n['" + akey + "'" + seen[lkey] + ']=1'
					+ '\n')
		}
	} else {
		// It's a positional argument
		allPositionalArgs.push(arg)
		output += '[' + ++pC + ']=' + arg + '\n'
	}
}

var fso = new ActiveXObject('Scripting.FileSystemObject')
var scriptName = WScript.ScriptName.replace(/\?\.wsf$/i, '')
var scriptFullName = WScript.ScriptFullName.replace(/\?\.wsf$/i, '')
output += ('[v]=1.1.0'
		+ '\n[m]=unix'
		+ '\n[0]=' + scriptName
		+ '\n[~n0]=' + fso.GetBaseName(scriptName)
		+ '\n[~x0]=.' + fso.GetExtensionName(scriptName)
		+ '\n[~nx0]=' + scriptName
		+ '\n[~f0]=' + scriptFullName
		+ '\n[~d0]=' + fso.GetDriveName(scriptFullName)
		+ '\n[~dp0]=' + fso.GetParentFolderName(scriptFullName)
		+ '\n[#a]=' + i
		+ '\n[#@]=' + i
		+ '\n[#p]=' + pC
		+ '\n[#]=' + pC
		+ '\n[#n]=' + nC
		+ '\n[#q]=' + qC
		+ '\n[#;]=' + qC
		+ '\n[@]=' + ('"' + allArgs.join('" "') + '"')
		+ '\n[*]=' + ('"' + allPositionalArgs.join('" "') + '"')
		+ '\n')

WScript.Echo(output)
