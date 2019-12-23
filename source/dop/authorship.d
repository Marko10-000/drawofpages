/* DrawOfPages: Take notes with touchscreen input.
 * Copyright (C) 2019  Marko Semet
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
module dop.authorship;

private
{
    import std.algorithm;
    import std.array;
    import std.json;

    struct __DataLoader
    {
        string[] authors;
        string[] translators;
        string[] artists;
        string[] documenters;
        string copyright_infos;
        string prog_version;

        /++
         + Loads a string list out of a json
         + Params:
         +     data = The source json list
         + Returns: The read list of strings. When empty null.
         +/
        static string[] loadArray(JSONValue[] data)
        {
            auto result = data.map!((x) => x.str).filter!((x) => x.length != 0).array;
            if(result.length == 0)
            {
                return null;
            }
            else
            {
                return result;
            }
        }

        /++
         + Load the base input from resource file "authors.json"
         + Returns: The loaded values
         +/
        static __DataLoader load()
        {
            __DataLoader result;
            auto data = parseJSON(import("dop/authors.json")).object;
            assert(data["authors"].type == JSONType.array);
            result.authors = loadArray(data["authors"].array);
            assert(data["translators"].type == JSONType.array);
            result.translators = loadArray(data["translators"].array);
            assert(data["artists"].type == JSONType.array);
            result.artists = loadArray(data["artists"].array);
            assert(data["documenters"].type == JSONType.array);
            result.documenters = loadArray(data["documenters"].array);
            assert(data["copyright_infos"].type == JSONType.string);
            result.copyright_infos = data["copyright_infos"].str;
            assert(data["version"].type == JSONType.string);
            result.prog_version = data["version"].str;
            return result;
        }
    }
    enum __DataLoader __loader = __DataLoader.load();       
}

public
{
    /++
     + List of the developers.
     +/
    enum string[] authorship_authors = __loader.authors;
    /++
     + List of the translators.
     +/
    enum string[] authorship_translators = __loader.translators;
    /++
     + List of the artists.
     +/
    enum string[] authorship_artists = __loader.artists;
    /++
     + List of the documenters.
     +/
    enum string[] authorship_documenters = __loader.documenters;
    /++
     + Additional copyright informations.
     +/
    enum string authorship_copyright_infos = __loader.copyright_infos;
    /++
     + The current programm version.
     +/
    enum string programm_version = __loader.prog_version;
}