// Author: Anirudh Sasikumar (http://anirudhs.chaosnet.org/)
// Copryright (C) 2009 Anirudh Sasikumar

// as3syntaxhighlight is a port of google-code-prettify from
// javascript to ActionScript 3. The AS3 version is strongly
// typed, has changes to recognize AS within MXML, syntax highlights
// function and var differently (.spl) so that coloring similar
// to flex builder 3 is possible. It also includes some changes
// which have been marked clearly as such.

// The async version is completely my own. It uses Alex Harui's
// pseudothread to syntax highlight as much as possible without
// blocking the UI. It splits the code into chunks, works on each chunk
// separately (but previous source and decoration info is maintained so
// syntax is correctly lexed.)

// The only tie in with Flex is PseudoThread. Otherwise this can be used
// as pure AS3.

// CodePrettyPrint class can output syntax highlighted code as HTML 
// or as a decorations array which contain indexes and associated style.
// The decorations can be leveraged for use in TextRange for in-place
// highlighting. Note that TextRange (actually setTextFormat) is slow
// compared to setting htmlText. The fastest way is to use the sync
// version to generate HTML and set that as htmlText.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Original license for javascript (google-code-prettify) version follows:

// Copyright (C) 2006 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/**
 * @fileoverview
 * some functions for browser-side pretty printing of code contained in html.
 *
 * The lexer should work on a number of languages including C and friends,
 * Java, Python, Bash, SQL, HTML, XML, CSS, Javascript, and Makefiles.
 * It works passably on Ruby, PHP and Awk and a decent subset of Perl, but,
 * because of commenting conventions, doesn't work on Smalltalk, Lisp-like, or
 * CAML-like languages.
 *
 * If there's a language not mentioned here, then I don't know it, and don't
 * know whether it works.  If it has a C-like, Bash-like, or XML-like syntax
 * then it should work passably.
 */
package net.anirudh.as3syntaxhighlight
{
	import mx.managers.ISystemManager;
	
    public class CodePrettyPrint
    {
        /** the number of characters between tab columns */
        private var PR_TAB_WIDTH:int = 8;
        
        /** Contains functions for creating and registering new language handlers.
         * @type {Object}
         */
        private var PR:Object;
        
        /**
         * A class that indicates a section of markup that is not code, e.g. to allow
         * embedding of line numbers within code listings.
         */
        private var PR_NOCODE:String = 'nocode';
        
        private function wordSet(words:Object):Object {
            words = words.split(/ /g);
            var set:Object = {};
            for (var i:int = words.length; --i >= 0;) {
                var w:Object = words[i];
                if (w) { set[w] = null; }
            }
            return set;
        }
        
        // Define regexps here so that the interpreter doesn't have to create an
        // object each time the function containing them is called.
        // The language spec requires a new object created even if you don't access
        // the $1 members.
        private var pr_amp:RegExp = /&/g;
		private var pr_lt:RegExp = /</g;
		private var pr_gt:RegExp = />/g;
		private var pr_quot:RegExp = new RegExp("\\\"", "g");
		
        /** like textToHtml but escapes double quotes to be attribute safe. */
        private function attribToHtml(str:String):String {
            return str.replace(pr_amp, '&amp;')
                .replace(pr_lt, '&lt;')
                .replace(pr_gt, '&gt;')
                .replace(pr_quot, '&quot;');
        }
        
        /** escapest html special characters to html. */
        public function textToHtml(str:String):String {
            return str.replace(pr_amp, '&amp;')
                .replace(pr_lt, '&lt;')
                .replace(pr_gt, '&gt;');
        }
        
        
        private var pr_ltEnt:RegExp = /&lt;/g;
        private var pr_gtEnt:RegExp = /&gt;/g;
        private var pr_aposEnt:RegExp = /&apos;/g;
        private var pr_quotEnt:RegExp = /&quot;/g;
        private var pr_ampEnt:RegExp = /&amp;/g;
        private var pr_nbspEnt:RegExp = /&nbsp;/g;
        
		public function CodePrettyPrint()
		{
			regexpPrecederPattern();
			registerLangHandler(decorateSource, ['default-code']);
			registerLangHandler(decorateMarkup,
				['default-markup', 'html', 'htm', 'xhtml', 'xml', 'xsl']);
		}
		
        /** unescapes html to plain text. */
        private function htmlToText(html:String):String {
            var pos:int = html.indexOf('&');
            if (pos < 0) { return html; }
            // Handle numeric entities specially.  We can't use functional substitution
            // since that doesn't work in older versions of Safari.
            // These should be rare since most browsers convert them to normal chars.
            for (--pos; (pos = html.indexOf('&#', pos + 1)) >= 0;) {
                var end:int = html.indexOf(';', pos);
                if (end >= 0) {
                    var num:String = html.substring(pos + 3, end);
                    var radix:int = 10;
                    if (num && num.charAt(0) === 'x') {
                        num = num.substring(1);
                        radix = 16;
                    }
                    var codePoint:Number = parseInt(num, radix);
                    if (!isNaN(codePoint)) {
                        html = (html.substring(0, pos) + String.fromCharCode(codePoint) +
                                html.substring(end + 1));
                    }
                }
            }
            
            return html.replace(pr_ltEnt, '<')
                .replace(pr_gtEnt, '>')
                .replace(pr_aposEnt, "'")
                .replace(pr_quotEnt, '"')
                .replace(pr_ampEnt, '&')
                .replace(pr_nbspEnt, ' ');
        }
        
        private static var KEYWORDS:String = "import use namespace " +
			"package class function const var " +
			"private protected public final dynamic extends implements static override get set " +
			"typeof instanceof with is as " +
			"throw try catch finally " +
			"void null undefined false true this super trace " +
			"new delete " +
			"if else do while switch case default for in foreach as continue break return ";
        
        // token style names.  correspond to css classes
        /** token style for a string literal */
        private static var PR_STRING:String = 'str';
        /** token style for a keyword */
        private static var PR_KEYWORD:String = 'kwd';
        /** token style for a comment */
        private static var PR_COMMENT:String = 'com';
        /** token style for a dosctring */
        private static var PR_DOCSTRING:String = 'docstring';
        /** token style for a type */
        private static var PR_TYPE:String = 'typ';
        /** token style for a literal value.  e.g. 1, null, true. */
        private static var PR_LITERAL:String = 'lit';
        /** token style for a punctuation string. */
        private static var PR_PUNCTUATION:String = 'pun';
        /** token style for a punctuation string. */
        private static var PR_PLAIN:String = 'pln';
        
        /** token style for an sgml tag. */
        private static var PR_TAG:String = 'tag';
        /** token style for a markup declaration such as a DOCTYPE. */
        private static var PR_DECLARATION:String = 'dec';
        /** token style for embedded source. */
        private static var PR_SOURCE:String = 'src';
        /** token style for an sgml attribute name. */
        private static var PR_ATTRIB_NAME:String = 'atn';
        /** token style for an sgml attribute value. */
        private static var PR_ATTRIB_VALUE:String = 'atv';
        
        private static function isWordChar(ch:String):Boolean 
        {
            return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
        }
        
        /** Splice one array into another.
         * Like the python <code>
         * container[containerPosition:containerPosition + countReplaced] = inserted
         * </code>
         * @param {Array} inserted
         * @param {Array} container modified in place
         * @param {Number} containerPosition
         * @param {Number} countReplaced
         */
        private function spliceArrayInto(
            inserted:Array, container:Array, containerPosition:Number, countReplaced:Number):void {
            inserted.unshift(containerPosition, countReplaced || 0);
            try {
                container.splice.apply(container, inserted);
            } finally {
                inserted.splice(0, 2);
            }
        }
        
        /** A set of tokens that can precede a regular expression literal in
         * javascript.
         * http://www.mozilla.org/js/language/js20/rationale/syntax.html has the full
         * list, but I've removed ones that might be problematic when seen in
         * languages that don't support regular expression literals.
         *
         * <p>Specifically, I've removed any keywords that can't precede a regexp
         * literal in a syntactically legal javascript program, and I've removed the
         * "in" keyword since it's not a keyword in many languages, and might be used
         * as a count of inches.
         * @private
         */
        private static function regexpPrecederPattern():RegExp 
        {
            var preceders:Array = [
                "!", "!=", "!==", "#", "%", "%=", "&", "&&", "&&=",
                "&=", "(", "*", "*=", /* "+", */ "+=", ",", /* "-", */ "-=",
                "->", /*".", "..", "...", handled below */ "/", "/=", ":", "::", ";",
                "<", "<<", "<<=", "<=", "=", "==", "===", ">",
                ">=", ">>", ">>=", ">>>", ">>>=", "?", "@", "[",
                "^", "^=", "^^", "^^=", "{", "|", "|=", "||",
                "||=", "~" /* handles =~ and !~ */,
                "break", "case", "continue", "delete",
                "do", "else", "finally", "instanceof",
                "return", "throw", "try", "typeof"
                                   ];
            var pattern:String = '(?:' +
            '(?:(?:^|[^0-9.])\\.{1,3})|' +  // a dot that's not part of a number
            '(?:(?:^|[^\\+])\\+)|' +  // allow + but not ++
            '(?:(?:^|[^\\-])-)';  // allow - but not --
            for (var i:int = 0; i < preceders.length; ++i) {
                var preceder:String = preceders[i];
                if (isWordChar(preceder.charAt(0))) {
                    pattern += '|\\b' + preceder;
                } else {
                    pattern += '|' + preceder.replace(/([^=<>:&])/g, '\\$1');
                }
            }
            pattern += '|^)\\s*$';  // matches at end, and matches empty string
            return new RegExp(pattern);
            // CAVEAT: this does not properly handle the case where a regular
            // expression immediately follows another since a regular expression may
            // have flags for case-sensitivity and the like.  Having regexp tokens
            // adjacent is not
            // valid in any language I'm aware of, so I'm punting.
            // TODO: maybe style special characters inside a regexp as punctuation.
        }

        private static var REGEXP_PRECEDER_PATTERN:Function = regexpPrecederPattern;
        
        // The below pattern matches one of the following
        // (1) /[^<]+/ : A run of characters other than '<'
        // (2) /<!--.*?-->/: an HTML comment
        // (3) /<!\[CDATA\[.*?\]\]>/: a cdata section
        // (3) /<\/?[a-zA-Z][^>]*>/ : A probably tag that should not be highlighted
        // (4) /</ : A '<' that does not begin a larger chunk.  Treated as 1
        private static var pr_chunkPattern:RegExp =
            /(?:[^<]+|<!--[\s\S]*?-->|<!\[CDATA\[([\s\S]*?)\]\]>|<\/?[a-zA-Z][^>]*>|<)/g;
        private static var pr_commentPrefix:RegExp = /^<!--/;
        private static var pr_cdataPrefix:RegExp = /^<\[CDATA\[/;
        private static var pr_brPrefix:RegExp = /^<br\b/i;
        private static var pr_tagNameRe:RegExp = /^<(\/?)([a-zA-Z]+)/;
        
        /** returns a function that expand tabs to spaces.  This function can be fed
         * successive chunks of text, and will maintain its own internal state to
         * keep track of how tabs are expanded.
         * @return {function (string) : string} a function that takes
         *   plain text and return the text with tabs expanded.
         * @private
         */
        private function makeTabExpander(tabWidth:int):Function {
            var SPACES:String = '                ';
            var charInLine:int = 0;
            
            return function (plainText:String):String {
                // walk over each character looking for tabs and newlines.
                // On tabs, expand them.  On newlines, reset charInLine.
                // Otherwise increment charInLine
                var out:Array = null;
                var pos:int = 0;
                for (var i:int = 0, n:int = plainText.length; i < n; ++i) {
                    var ch:String = plainText.charAt(i);
                    
                    switch (ch) {
                        case '\t':
                            if (!out) { out = []; }
                            out.push(plainText.substring(pos, i));
                            // calculate how much space we need in front of this part
                            // nSpaces is the amount of padding -- the number of spaces needed
                            // to move us to the next column, where columns occur at factors of
                            // tabWidth.
                            var nSpaces:int = tabWidth - (charInLine % tabWidth);
                            charInLine += nSpaces;
                            for (; nSpaces >= 0; nSpaces -= SPACES.length) {
                                out.push(SPACES.substring(0, nSpaces));
                            }
                            pos = i + 1;
                            break;
                        case '\n':
                            charInLine = 0;
                            break;
                        default:
                            ++charInLine;
                    }
                }
                if (!out) { return plainText; }
                out.push(plainText.substring(pos));
                return out.join('');
            };
        }
        
        /** split markup into chunks of html tags (style null) and
         * plain text (style {@link #PR_PLAIN}), converting tags which are
         * significant for tokenization (<br>) into their textual equivalent.
         *
         * @param {string} s html where whitespace is considered significant.
         * @return {Object} source code and extracted tags.
         * @private
         */
        private function extractTags(s:String):Object {
            // since the pattern has the 'g' modifier and defines no capturing groups,
            // this will return a list of all chunks which we then classify and wrap as
            // PR_Tokens
            var matches:Array = s.match(pr_chunkPattern);
            var sourceBuf:Array = [];
            var sourceBufLen:int = 0;
            var extractedTags:Array = [];
            if (matches) {
                for (var i:int = 0, n:int = matches.length; i < n; ++i) {
                    var match:String = matches[i];
                    if (match.length > 1 && match.charAt(0) === '<') {
                        if (pr_commentPrefix.test(match)) { continue; }
                        if (pr_cdataPrefix.test(match)) {
                            // strip CDATA prefix and suffix.  Don't unescape since it's CDATA
                            sourceBuf.push(match.substring(9, match.length - 3));
                            sourceBufLen += match.length - 12;
                        } else if (pr_brPrefix.test(match)) {
                            // <br> tags are lexically significant so convert them to text.
                            // This is undone later.
                            sourceBuf.push('\n');
                            ++sourceBufLen;
                        } else {
                            if (match.indexOf(PR_NOCODE) >= 0 && isNoCodeTag(match)) {
                                // A <span class="nocode"> will start a section that should be
                                // ignored.  Continue walking the list until we see a matching end
                                // tag.
                                var name:String = match.match(pr_tagNameRe)[2];
                                var depth:int = 1;
                              end_tag_loop:
                                for (var j:int = i + 1; j < n; ++j) {
                                    var name2:Array = matches[j].match(pr_tagNameRe);
                                    if (name2 && name2[2] === name) {
                                        if (name2[1] === '/') {
                                            if (--depth === 0) { break end_tag_loop; }
                                        } else {
                                            ++depth;
                                        }
                                    }
                                }
                                if (j < n) {
                                    extractedTags.push(
                                        sourceBufLen, matches.slice(i, j + 1).join(''));
                                    i = j;
                                } else {  // Ignore unclosed sections.
                                    extractedTags.push(sourceBufLen, match);
                                }
                            } else {
                                extractedTags.push(sourceBufLen, match);
                            }
                        }
                    } else {
                        var literalText:String = htmlToText(match);
                        sourceBuf.push(literalText);
                        sourceBufLen += literalText.length;
                    }
                }
            }
            return { source: sourceBuf.join(''), tags: extractedTags };
        }
        
        /** True if the given tag contains a class attribute with the nocode class. */
        private function isNoCodeTag(tag:String):Boolean {
            return !!tag
                // First canonicalize the representation of attributes
                .replace(/\s(\w+)\s*=\s*(?:\"([^\"]*)\"|'([^\']*)'|(\S+))/g,
                         ' $1="$2$3$4"')
                // Then look for the attribute we want.
                .match(/[cC][lL][aA][sS][sS]=\"[^\"]*\bnocode\b/);
        }
        
        /** Given triples of [style, pattern, context] returns a lexing function,
         * The lexing function interprets the patterns to find token boundaries and
         * returns a decoration list of the form
         * [index_0, style_0, index_1, style_1, ..., index_n, style_n]
         * where index_n is an index into the sourceCode, and style_n is a style
         * constant like PR_PLAIN.  index_n-1 <= index_n, and style_n-1 applies to
         * all characters in sourceCode[index_n-1:index_n].
         *
         * The stylePatterns is a list whose elements have the form
         * [style : string, pattern : RegExp, context : RegExp, shortcut : string].
         &
         * Style is a style constant like PR_PLAIN.
         *
         * Pattern must only match prefixes, and if it matches a prefix and context
         * is null or matches the last non-comment token parsed, then that match is
         * considered a token with the same style.
         *
         * Context is applied to the last non-whitespace, non-comment token
         * recognized.
         *
         * Shortcut is an optional string of characters, any of which, if the first
         * character, gurantee that this pattern and only this pattern matches.
         *
         * @param {Array} shortcutStylePatterns patterns that always start with
         *   a known character.  Must have a shortcut string.
         * @param {Array} fallthroughStylePatterns patterns that will be tried in
         *   order if the shortcut ones fail.  May have shortcuts.
         *
         * @return {function (string, number?) : Array.<number|string>} a
         *   function that takes source code and returns a list of decorations.
         */
        private function createSimpleLexer(shortcutStylePatterns:Array,
                                   fallthroughStylePatterns:Array):Function {
            var shortcuts:Object = {};
            (function ():void {
                var allPatterns:Array = shortcutStylePatterns.concat(fallthroughStylePatterns);
                for (var i:int = allPatterns.length; --i >= 0;) {
                    var patternParts:Object = allPatterns[i];
                    var shortcutChars:Object = patternParts[3];
                    if (shortcutChars) {
                        for (var c:int = shortcutChars.length; --c >= 0;) {
                            shortcuts[shortcutChars.charAt(c)] = patternParts;
                        }
                    }
                }
            })();
            
            var nPatterns:int = fallthroughStylePatterns.length;
            var notWs:RegExp = /\S/;
            
            return function (sourceCode:String, opt_basePos:int=0):Array {
                opt_basePos = opt_basePos || 0;
                var decorations:Array = [opt_basePos, PR_PLAIN];
                var lastToken:String = '';
                var pos:int = 0;  // index into sourceCode
                var tail:String = sourceCode;
                
                while (tail.length) {
                    var style:String;
                    var token:String = null;
                    var match:Array;
                    
                    var patternParts:Array = shortcuts[tail.charAt(0)];
                    if (patternParts) {
                        match = tail.match(patternParts[1]);
						if(match)
						{
	                        token = match[0];
	                   
	                        style = patternParts[0];
						}
                    } else {
                        for (var i:int = 0; i < nPatterns; ++i) {
                            patternParts = fallthroughStylePatterns[i];
                            //Anirudh: should contextPattern be RegExp?
                            var contextPattern:RegExp = patternParts[2];
                            /* Changed by anirudh. fix this */
                            if (contextPattern && contextPattern is RegExp && !contextPattern.test(lastToken)) {
                                // rule can't be used
                                continue;
                            }
                            match = tail.match(patternParts[1]);
                            if (match) {
                                token = match[0];
                             
                                	
                                style = patternParts[0];
								
								if (token == "class") 
								{
			                   		style = "class";
			                   	}
								else if (token == "package") 
								{
			                   		style = "package";
			                   	}
								else if (token == "function")
								{
			                   		style = "function";
			                   	}
								else if (token == "var") 
								{
			                   		style = "var";
			                   	}
								else if (token == "trace") 
								{
			                   		style = "trace";
			                   	}
								else if (token == "undefined") 
								{
			                   		style = "undefined";
			                   	}
                                break;
                            }
                        }
                    }
					
                    if (!token) {  // make sure that we make progress
                        style = PR_PLAIN;
                        token = tail.substring(0, 1);
                    }
                   //trace("found special keywords " + token  + " " + style);
                  
                    
                    decorations.push(opt_basePos + pos, style);
                    pos += token.length;
                    tail = tail.substring(token.length);
                    if (style !== PR_COMMENT && notWs.test(token)) { lastToken = token; }
                }
                return decorations;
            };
        }
        
        private var PR_MARKUP_LEXER:Function = createSimpleLexer([],[
                                                    [PR_PLAIN,       /^[^<]+/, null],
                                                    [PR_DECLARATION, /^<!\w[^>]*(?:>|$)/, null],
                                                    [PR_COMMENT,     /^<!--[\s\S]*?(?:-->|$)/, null],
                                                    [PR_SOURCE,      /^<\?[\s\S]*?(?:\?>|$)/, null],
                                                    [PR_SOURCE,      /^<%[\s\S]*?(?:%>|$)/, null],
                                                    [PR_SOURCE,
                                                     // Tags whose content is not escaped, and which contain source code.
                                                     /^<(script|style|xmp|mx\:Script)\b[^>]*>[\s\S]*?<\/\1\b[^>]*>/i, null],
                                                    [PR_TAG,         /^<\/?\w[^<>]*>/, null]]);
        // Splits any of the source|style|xmp entries above into a start tag,
        // source content, and end tag.
        private var PR_SOURCE_CHUNK_PARTS:RegExp = /^(<[^>]*>)([\s\S]*)(<\/[^>]*>)$/;
		
        /** split markup on tags, comments, application directives, and other top
         * level constructs.  Tags are returned as a single token - attributes are
         * not yet broken out.
         * @private
         */
        private function tokenizeMarkup(source:String):Array {
            var decorations:Array = PR_MARKUP_LEXER(source);
            for (var i:int = 0; i < decorations.length; i += 2) {
                if (decorations[i + 1] === PR_SOURCE) {
                    var start:int, end:int;
                    start = decorations[i];
                    end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                    // Split out start and end script tags as actual tags, and leave the
                    // body with style SCRIPT.
                    var sourceChunk:String = (source as String).substring(start, end);
                    var match:Array = sourceChunk.match(PR_SOURCE_CHUNK_PARTS);
                    if ( match && match.length > 2 ) {
                        decorations.splice(
                            i, 2,
                            start, PR_TAG,  // the open chunk
                            start + (match[1] as String).length, PR_SOURCE,
                            start + (match[1] as String).length + ((match[2] as String) || '').length, PR_TAG);
                    }
                }
            }
            return decorations;
        }
        
        private var PR_TAG_LEXER:Function = createSimpleLexer([
                                                 [PR_ATTRIB_VALUE, /^\'[^\']*(?:\'|$)/, null, "'"],
                                                 [PR_ATTRIB_VALUE, /^\"[^\"]*(?:\"|$)/, null, '"'],
                                                 [PR_PUNCTUATION,  /^[<>\/=]+/, null, '<>/=']
                                              ], [
                                                  [PR_TAG,          /^[\w:\-]+/, /^</],
                                                  [PR_ATTRIB_VALUE, /^[\w\-]+/, /^=/],
                                                  [PR_ATTRIB_NAME,  /^[\w:\-]+/, null],
                                                  [PR_PLAIN,        /^\s+/, null, ' \t\r\n']
                                                  ]);
        /** split tags attributes and their values out from the tag name, and
         * recursively lex source chunks.
         * @private
         */
        private function splitTagAttributes(source:String, decorations:Array):Array {
            for (var i:int = 0; i < decorations.length; i += 2) {
            	//should style be a String?
                var style:Object = decorations[i + 1];
                if (style === PR_TAG) {
                    var start:int, end:int;
                    start = decorations[i];
                    end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                    var chunk:String = source.substring(start, end);
                    var subDecorations:Array = PR_TAG_LEXER(chunk, start);
                    spliceArrayInto(subDecorations, decorations, i, 2);
                    i += subDecorations.length - 2;
                }
            }
            return decorations;
        }
        
        /** returns a function that produces a list of decorations from source text.
         *
         * This code treats ", ', and ` as string delimiters, and \ as a string
         * escape.  It does not recognize perl's qq() style strings.
         * It has no special handling for double delimiter escapes as in basic, or
         * the tripled delimiters used in python, but should work on those regardless
         * although in those cases a single string literal may be broken up into
         * multiple adjacent string literals.
         *
         * It recognizes C, C++, and shell style comments.
         *
         * @param {Object} options a set of optional parameters.
         * @return {function (string) : Array.<string|number>} a
         *     decorator that takes sourceCode as plain text and that returns a
         *     decoration list
         */
        private function sourceDecorator(options:Object):Function {
            var shortcutStylePatterns:Array = [], fallthroughStylePatterns:Array = [];
            if (options.tripleQuotedStrings) {
                // '''multi-line-string''', 'single-line-string', and double-quoted
                shortcutStylePatterns.push(
                    [PR_STRING,  /^(?:\'\'\'(?:[^\'\\]|\\[\s\S]|\'{1,2}(?=[^\']))*(?:\'\'\'|$)|\"\"\"(?:[^\"\\]|\\[\s\S]|\"{1,2}(?=[^\"]))*(?:\"\"\"|$)|\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$))/,
                     null, '\'"']);
            } else if (options.multiLineStrings) {
                // 'multi-line-string', "multi-line-string"
                shortcutStylePatterns.push(
                    [PR_STRING,  /^(?:\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$)|\`(?:[^\\\`]|\\[\s\S])*(?:\`|$))/,
                     null, '\'"`']);
            } else {
                // 'single-line-string', "single-line-string"
                shortcutStylePatterns.push(
                    [PR_STRING,
                     /^(?:\'(?:[^\\\'\r\n]|\\.)*(?:\'|$)|\"(?:[^\\\"\r\n]|\\.)*(?:\"|$))/,
                     null, '"\'']);
            }
            fallthroughStylePatterns.push(
                [PR_PLAIN,   /^(?:[^\'\"\`\/\#]+)/, null, ' \r\n']);
			
			//inline comments
            fallthroughStylePatterns.push([PR_COMMENT, /^\/\/[^\r\n]*/, null]);
			
			//docstrings
            fallthroughStylePatterns.push([PR_DOCSTRING, /^\/\*\*[\s\S]*?(?:\*\/|$)/, null]);
			
			//block comments
            fallthroughStylePatterns.push([PR_COMMENT, /^\/\*[\s\S]*?(?:\*\/|$)/, null]);
			
            if (options.regexLiterals) {
                var REGEX_LITERAL:String = (
                    // A regular expression literal starts with a slash that is
                    // not followed by * or / so that it is not confused with
                    // comments.
                    '^/(?=[^/*])'
                    // and then contains any number of raw characters,
                    + '(?:[^/\\x5B\\x5C\\x0A\\x0D]'
                    // escape sequences (\x5C),
                    +    '|\\x5C[\\t \\S]'
                    // or non-nesting character sets (\x5B\x5D);
                    +    '|\\x5B(?:[^\\x5C\\x5D]|\\x5C[\\t \\S])*(?:\\x5D|$))+'
                    // finally closed by a /.
                    + '(?:/|$)');
                fallthroughStylePatterns.push(
                    [PR_STRING, new RegExp(REGEX_LITERAL), REGEXP_PRECEDER_PATTERN]);
            }
            
            var keywords:Object = wordSet(options.keywords);
            
            options = null;
            
            /** splits the given string into comment, string, and "other" tokens.
             * @param {string} sourceCode as plain text
             * @return {Array.<number|string>} a decoration list.
             * @private
             */
            var splitStringAndCommentTokens:Function = createSimpleLexer(
                shortcutStylePatterns, fallthroughStylePatterns);
            
            var styleLiteralIdentifierPuncRecognizer:Function = createSimpleLexer([], [
                                                                             [PR_PLAIN,       /^\s+/, null, ' \r\n'],
                                                                             // TODO(mikesamuel): recognize non-latin letters and numerals in idents
                                                                             [PR_PLAIN,       /^[a-z_$@][a-z_$@0-9]*/i, null],
                                                                             // A hex number
                                                                             [PR_LITERAL,     /^0x[a-f0-9]+[a-z]/i, null],
                                                                             // An octal or decimal number, possibly in scientific notation
                                                                             [PR_LITERAL,
                                                                              /^(?:\d(?:_\d+)*\d*(?:\.\d*)?|\.\d+)(?:e[+\-]?\d+)?[a-z]*/i,
                                                                              null, '123456789'],
                                                                             [PR_PUNCTUATION, /^[^\s\w\.$@]+/, null]
                                                                             // Fallback will handle decimal points not adjacent to a digit
                                                                              ]);
            
            /** splits plain text tokens into more specific tokens, and then tries to
             * recognize keywords, and types.
             * @private
             */
            function splitNonStringNonCommentTokens(source:String, decorations:Array):Array {
                for (var i:int = 0; i < decorations.length; i += 2) {
                    var style:Object = decorations[i + 1];
                    if (style === PR_PLAIN) {
                        var start:int, end:int, chunk:String, subDecs:Array;
                        start = decorations[i];
                        end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                        chunk = source.substring(start, end);
                        subDecs = styleLiteralIdentifierPuncRecognizer(chunk, start);
                        for (var j:int = 0, m:int = subDecs.length; j < m; j += 2) {
                            var subStyle:String = subDecs[j + 1];
                            if (subStyle === PR_PLAIN) {
                                var subStart:int = subDecs[j];
                                var subEnd:int = j + 2 < m ? subDecs[j + 2] : chunk.length;
                                var token:String = source.substring(subStart, subEnd);
                                if (token === '.') {
                                    subDecs[j + 1] = PR_PUNCTUATION;
                                } else if (token in keywords) {
                                    subDecs[j + 1] = PR_KEYWORD;
                                } else if (/^@?[A-Z][A-Z$]*[a-z][A-Za-z$]*$/.test(token)) {
                                    // classify types and annotations using Java's style conventions
                                    subDecs[j + 1] = token.charAt(0) === '@' ? PR_LITERAL : PR_TYPE;
                                }
                            }
                        }
                        spliceArrayInto(subDecs, decorations, i, 2);
                        i += subDecs.length - 2;
                    }
                }
                return decorations;
            }
            
            return function (sourceCode:String):Array {
                // Split into strings, comments, and other.
                // We do this because strings and comments are easily recognizable and can
                // contain stuff that looks like other tokens, so we want to mark those
                // early so we don't recurse into them.
                var decorations:Array = splitStringAndCommentTokens(sourceCode);
                
                // Split non comment|string tokens on whitespace and word boundaries
                decorations = splitNonStringNonCommentTokens(sourceCode, decorations);
                
                return decorations;
            }
        }
        
        private var decorateSource:Function = sourceDecorator({
              keywords: KEYWORDS,
              hashComments: false,
              cStyleComments: true,
			  docStrings: true,
              multiLineStrings: false,
              //regexLiterals: true
              //Change by Anirudh
              regexLiterals: true
            });
        
        /** identify regions of markup that are really source code, and recursivley
         * lex them.
         * @private
         */
        private function splitSourceNodes(source:String, decorations:Array):Array {
            for (var i:int = 0; i < decorations.length; i += 2) {
                var style:Object = decorations[i + 1];
                if (style === PR_SOURCE) {
                    // Recurse using the non-markup lexer
                    var start:int, end:int;
                    start = decorations[i];
                    end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                    var subDecorations:Array = decorateSource(source.substring(start, end));
                    for (var j:int = 0, m:int = subDecorations.length; j < m; j += 2) {
                        subDecorations[j] += start;
                    }
                    spliceArrayInto(subDecorations, decorations, i, 2);
                    i += subDecorations.length - 2;
                }
            }
            return decorations;
        }
        
        private var quoteReg:RegExp = new RegExp("^[\\\"\\']","");
        
        /** identify attribute values that really contain source code and recursively
         * lex them.
         * @private
         */
        private function splitSourceAttributes(source:String, decorations:Array):Array {
            var nextValueIsSource:Boolean = false;
            for (var i:int = 0; i < decorations.length; i += 2) {
                var style:Object = decorations[i + 1];
                var start:int, end:int;
                if (style === PR_ATTRIB_NAME) {
                    start = decorations[i];
                    end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                    nextValueIsSource = /^on|^style$/i.test(source.substring(start, end));
                } else if (style === PR_ATTRIB_VALUE) {
                    if (nextValueIsSource) {
                        start = decorations[i];
                        end = i + 2 < decorations.length ? decorations[i + 2] : source.length;
                        var attribValue:String = source.substring(start, end);
                        var attribLen:int = attribValue.length;
                        var quoted:Boolean =
                            //(attribLen >= 2 && /^[\"\']/.test(attribValue) &&
                            (attribLen >= 2 && quoteReg.test(attribValue) &&
                             attribValue.charAt(0) === attribValue.charAt(attribLen - 1));
                        
                        var attribSource:String;
                        var attribSourceStart:int;
                        var attribSourceEnd:int;
                        if (quoted) {
                            attribSourceStart = start + 1;
                            attribSourceEnd = end - 1;
                            attribSource = attribValue;
                        } else {
                            attribSourceStart = start + 1;
                            attribSourceEnd = end - 1;
                            attribSource = attribValue.substring(1, attribValue.length - 1);
                        }
                        
                        var attribSourceDecorations:Array = decorateSource(attribSource);
                        for (var j:int = 0, m:int = attribSourceDecorations.length; j < m; j += 2) {
                            attribSourceDecorations[j] += attribSourceStart;
                        }
                        
                        if (quoted) {
                            attribSourceDecorations.push(attribSourceEnd, PR_ATTRIB_VALUE);
                            spliceArrayInto(attribSourceDecorations, decorations, i + 2, 0);
                        } else {
                            spliceArrayInto(attribSourceDecorations, decorations, i, 2);
                        }
                    }
                    nextValueIsSource = false;
                }
            }
            return decorations;
        }
        
        /** returns a decoration list given a string of markup.
         *
         * This code recognizes a number of constructs.
         * <!-- ... --> comment
         * <!\w ... >   declaration
         * <\w ... >    tag
         * </\w ... >   tag
         * <?...?>      embedded source
         * <%...%>      embedded source
         * &[#\w]...;   entity
         *
         * It does not recognizes %foo; doctype entities from  .
         *
         * It will recurse into any <style>, <script>, and on* attributes using
         * PR_lexSource.
         */
        private function decorateMarkup(sourceCode:String):Array {
            // This function works as follows:
            // 1) Start by splitting the markup into text and tag chunks
            //    Input:  string s
            //    Output: List<PR_Token> where style in (PR_PLAIN, null)
            // 2) Then split the text chunks further into comments, declarations,
            //    tags, etc.
            //    After each split, consider whether the token is the start of an
            //    embedded source section, i.e. is an open <script> tag.  If it is, find
            //    the corresponding close token, and don't bother to lex in between.
            //    Input:  List<string>
            //    Output: List<PR_Token> with style in
            //            (PR_TAG, PR_PLAIN, PR_SOURCE, null)
            // 3) Finally go over each tag token and split out attribute names and
            //    values.
            //    Input:  List<PR_Token>
            //    Output: List<PR_Token> where style in
            //            (PR_TAG, PR_PLAIN, PR_SOURCE, NAME, VALUE, null)
            var decorations:Array = tokenizeMarkup(sourceCode);
            decorations = splitTagAttributes(sourceCode, decorations);
            decorations = splitSourceNodes(sourceCode, decorations);
            decorations = splitSourceAttributes(sourceCode, decorations);
            return decorations;
        }
        
        //Added by Anirudh
        public var mainDecorations:Array;
        
        /**
         * @param {string} sourceText plain text
         * @param {Array.<number|string>} extractedTags chunks of raw html preceded
         *   by their position in sourceText in order.
         * @param {Array.<number|string>} decorations style classes preceded by their
         *   position in sourceText in order.
         * @return {string} html
         * @private
         */         
        private function recombineTagsAndDecorations(sourceText:String, extractedTags:Array, decorations:Array):String {
            var html:Array = [];
            // index past the last char in sourceText written to html
            var outputIdx:int = 0;
            //mainDecorations = decorations;
            
            var openDecoration:String = null;
            var currentDecoration:String = null;
            var tagPos:int = 0;  // index into extractedTags
            var decPos:int = 0;  // index into decorations
            var tabExpander:Function = makeTabExpander(PR_TAB_WIDTH);
            
            var adjacentSpaceRe:RegExp = /([\r\n ]) /g;
            var startOrSpaceRe:RegExp = /(^| ) /gm;
            var newlineRe:RegExp = /\r\n?|\n/g;
            var trailingSpaceRe:RegExp = /[ \r\n]$/;
            var lastWasSpace:Boolean = true;  // the last text chunk emitted ended with a space.
            
            // A helper function that is responsible for opening sections of decoration
            // and outputing properly escaped chunks of source
            function emitTextUpTo(sourceIdx:int):void {
                if (sourceIdx > outputIdx) {
                    if (openDecoration && openDecoration !== currentDecoration) {
                        // Close the current decoration
                        html.push('</span>');
                        openDecoration = null;
                    }
                    if (!openDecoration && currentDecoration) {
                        openDecoration = currentDecoration;
                        html.push('<span class="', openDecoration, '">');
                    }
                    // This interacts badly with some wikis which introduces paragraph tags
                    // into pre blocks for some strange reason.
                    // It's necessary for IE though which seems to lose the preformattedness
                    // of <pre> tags when their innerHTML is assigned.
                    // http://stud3.tuwien.ac.at/~e0226430/innerHtmlQuirk.html
                    // and it serves to undo the conversion of <br>s to newlines done in
                    // chunkify.
					/*
                    var htmlChunk:String = textToHtml(
                        tabExpander(sourceText.substring(outputIdx, sourceIdx)))
                        .replace(lastWasSpace
                                 ? startOrSpaceRe
                                 : adjacentSpaceRe, '$1&nbsp;');
					*/
                    var htmlChunk:String = textToHtml(
                        tabExpander(sourceText.substring(outputIdx, sourceIdx)));
                    // Keep track of whether we need to escape space at the beginning of the
                    // next chunk.
                    lastWasSpace = trailingSpaceRe.test(htmlChunk);
                    html.push(htmlChunk.replace(newlineRe, '<br />'));
                    outputIdx = sourceIdx;
                }
            }
            
            while (true) {
                // Determine if we're going to consume a tag this time around.  Otherwise
                // we consume a decoration or exit.
                var outputTag:Object;
                if (tagPos < extractedTags.length) {
                    if (decPos < decorations.length) {
                        // Pick one giving preference to extractedTags since we shouldn't open
                        // a new style that we're going to have to immediately close in order
                        // to output a tag.
                        outputTag = extractedTags[tagPos] <= decorations[decPos];
                    } else {
                        outputTag = true;
                    }
                } else {
                    outputTag = false;
                }
                // Consume either a decoration or a tag or exit.
                if (outputTag) {
                    emitTextUpTo(extractedTags[tagPos]);
                    if (openDecoration) {
                        // Close the current decoration
                        html.push('</span>');
                        openDecoration = null;
                    }
                    html.push(extractedTags[tagPos + 1]);
                    tagPos += 2;
                } else if (decPos < decorations.length) {
                    emitTextUpTo(decorations[decPos]);
                    currentDecoration = decorations[decPos + 1];
                    decPos += 2;
                } else {
                    break;
                }
            }
            emitTextUpTo(sourceText.length);
            if (openDecoration) {
                html.push('</span>');
            }
            
            return html.join('');
        }
        
        /** Maps language-specific file extensions to handlers. */
        private var langHandlerRegistry:Object = {};
        /** Register a language handler for the given file extensions.
         * @param {function (string) : Array.<number|string>} handler
         *     a function from source code to a list of decorations.
         * @param {Array.<string>} fileExtensions
         */
        private function registerLangHandler(handler:Function, fileExtensions:Array):void {
            for (var i:int = fileExtensions.length; --i >= 0;) {
                var ext:Object = fileExtensions[i];
                if (!langHandlerRegistry.hasOwnProperty(ext)) {
                    langHandlerRegistry[ext] = handler;
                } else  {
                    trace('cannot override language handler %s', ext);
                }
            }
        }
        
        // Anirudh: Parsing existing HTML has been removed. The commented out line is still there though
        // This class contains functionality to parse generated HTML to rebuild the decorations array
        // this is unused as of now. To optimize, extractTags() and its dependant functions can be 
        // removed
        public function prettyPrintOne(sourceCodeHtml:String, opt_langExtension:String, buildHTML:Boolean=false):String
        {
        	mainDecorations = null;
            // Extract tags, and convert the source code to plain text.       
            //Anirudh: Change not to do HTML extraction         
            //var sourceAndExtractedTags:Object = extractTags(sourceCodeHtml);                                
            //var sourceAndExtractedTags:Object = {source: sourceCodeHtml, tags: []};
            
            // Pick a lexer and apply it.
            if (!langHandlerRegistry.hasOwnProperty(opt_langExtension)) {
                // Treat it as markup if the first non whitespace character is a < and
                // the last non-whitespace character is a >.
                var checkmark:RegExp = /^\s*?</;
                opt_langExtension =
                    checkmark.test(sourceCodeHtml) ? 'default-markup' : 'default-code';
            }
            
            /** Even entries are positions in source in ascending order.  Odd enties
             * are style markers (e.g., PR_COMMENT) that run from that position until
             * the end.
             * @type {Array.<number|string>}
             */
            var decorations:Array = langHandlerRegistry[opt_langExtension].call({}, sourceCodeHtml);
            mainDecorations = decorations;
            //Anirudh: added buildHTML variable, because during live syntax highlighting, I 
            //just need the mainDecorations to apply the correct TextRange sections
            if ( buildHTML )
            {
            	/** Even entries are positions in source in ascending order.  Odd entries
                 * are tags that were extracted at that position.
                 * @type {Array.<number|string>}
                 */
            	var extractedTags:Array = [];
                // Integrate the decorations and tags back into the source code to produce
                // a decorated html string.
	            return recombineTagsAndDecorations(sourceCodeHtml, extractedTags, decorations);                	
            }
            return null;
        }
    }
}
