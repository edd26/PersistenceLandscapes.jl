#     Copyright 2013-2014 University of Pennsylvania
#     Created by Pawel Dlotko
# 
#     This file is part of Persistence Landscape Toolbox (PLT).
# 
#     PLT is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     PLT is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
# 
#     You should have received a copy of the GNU Lesser General Public License
#     along with PLT.  If not, see <http://www.gnu.org/licenses/>.



#pragma once

#include "PersistenceBarcode.h"
#include "PersistenceLandscape.h"


# This procedure is designed to read file names from a file provided by user and return vector of those names.
function vector<string> readFileNames( char* filenameWithFilenames )

    bool dbg = false

    vector<string> result
    ifstream in
    in.open( filenameWithFilenames )
    string line
    while (!in.eof())
        getline(in,line)
        line.erase( remove_if( line.begin(), line.end(), ::isspace) , line.end() )

        dbg && println("line : $(line)")

        if ( (line.length() == 0) || (line[0] == '#') )
            # in this case we have a file name. First we should remove all the white spaces.
            dbg && println("This is a line with comment, it will be ignored n")
        else
            result.push_back( line )
            dbg && println("Line after removing white spaces : $(line)")
        end
	end
    in.close()

    /*
    println("Read the following files from the file : $(filenameWithFilenames)")
    for i = 0:size(result,1) 
        cerr << result[i] << endl
    end
    cerr << endl
    */

    return result
end# readFileNames


# This procedure reads all the files named in the vector<string>. It can read both barcode files and landscape files. But in the case of landsape files, we assume that the extension is
# '.lan'.
function vector< PersistenceLandscape > createLandscapesFromTheFiles( vector<string> filenames )

    bool dbg = true

    vector< PersistenceLandscape > result
    for fileNo = 0:size(filenames,1) 
        # now reading file filenames[fileNo]
        char* filename = (char*)filenames[fileNo].c_str()

        # first we need to check if it is a barcode, or .lan file.
        bool isThisBarcodeFile = true
        if ( filenames[fileNo].size() > 4 )
            # check if last four characters in the name of the file is '.lan'.
           l = filenames[fileNo].size()
            if ( (filenames[fileNo][l-1] == 'n') && (filenames[fileNo][l-2] == 'a') && (filenames[fileNo][l-3] == 'l') && (filenames[fileNo][l-4] == '.') )
                isThisBarcodeFile = false
            end
        end

        dbg && println("Considering a file : " << filename)
        dbg && println("isThisBarcodeFile : " << isThisBarcodeFile)

        if ( isThisBarcodeFile )
            dbg && println("This is a barcode file")
            PersistenceBarcodes b( filename )
            PersistenceLandscape l(b)
            result.push_back(l)
        else
            dbg && println("This is a landscape file")
            PersistenceLandscape l( filename )
            result.push_back(l)
        end
    end
    return result
end# createLandscapesFromTheFiles



# This procedure reads all the files named in the vector<string>. They all asume to store barcode
function vector< PersistenceBarcodes > createBarcodesFromTheFiles( vector<string> filenames )

    bool dbg = true

    vector< PersistenceBarcodes > result
    for fileNo = 0:size(filenames,1)
        # now reading file filenames[fileNo]
        char* filename = (char*)filenames[fileNo].c_str()

        # first we need to check if it is a barcode, or .lan file.
        b = PersistenceBarcodes( filename )
        result.push_back(b)
    end
    return result
end# createLandscapesFromTheFiles
