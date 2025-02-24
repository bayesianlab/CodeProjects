%% Import data from text file.
% Script for importing data from the following text file:
%
%    /home/precision/GoogleDrive/Datasets/housing/state_housing.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2019/04/16 09:51:24

%% Initialize variables.
filename = '/home/precision/GoogleDrive/Datasets/housing/state_housing_no_north_dakota.csv';
delimiter = ',';
startRow = 2;

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
statehousing = table;
statehousing.V1 = cell2mat(raw(:, 1));
statehousing.V2 = cell2mat(raw(:, 2));
statehousing.V3 = cell2mat(raw(:, 3));
statehousing.V4 = cell2mat(raw(:, 4));
statehousing.V5 = cell2mat(raw(:, 5));
statehousing.V6 = cell2mat(raw(:, 6));
statehousing.V7 = cell2mat(raw(:, 7));
statehousing.V8 = cell2mat(raw(:, 8));
statehousing.V9 = cell2mat(raw(:, 9));
statehousing.V10 = cell2mat(raw(:, 10));
statehousing.V11 = cell2mat(raw(:, 11));
statehousing.V12 = cell2mat(raw(:, 12));
statehousing.V13 = cell2mat(raw(:, 13));
statehousing.V14 = cell2mat(raw(:, 14));
statehousing.V15 = cell2mat(raw(:, 15));
statehousing.V16 = cell2mat(raw(:, 16));
statehousing.V17 = cell2mat(raw(:, 17));
statehousing.V18 = cell2mat(raw(:, 18));
statehousing.V19 = cell2mat(raw(:, 19));
statehousing.V20 = cell2mat(raw(:, 20));
statehousing.V21 = cell2mat(raw(:, 21));
statehousing.V22 = cell2mat(raw(:, 22));
statehousing.V23 = cell2mat(raw(:, 23));
statehousing.V24 = cell2mat(raw(:, 24));
statehousing.V25 = cell2mat(raw(:, 25));
statehousing.V26 = cell2mat(raw(:, 26));
statehousing.V27 = cell2mat(raw(:, 27));
statehousing.V28 = cell2mat(raw(:, 28));
statehousing.V29 = cell2mat(raw(:, 29));
statehousing.V30 = cell2mat(raw(:, 30));
statehousing.V31 = cell2mat(raw(:, 31));
statehousing.V32 = cell2mat(raw(:, 32));
statehousing.V33 = cell2mat(raw(:, 33));
statehousing.V34 = cell2mat(raw(:, 34));
statehousing.V35 = cell2mat(raw(:, 35));
statehousing.V36 = cell2mat(raw(:, 36));
statehousing.V37 = cell2mat(raw(:, 37));
statehousing.V38 = cell2mat(raw(:, 38));
statehousing.V39 = cell2mat(raw(:, 39));
statehousing.V40 = cell2mat(raw(:, 40));
statehousing.V41 = cell2mat(raw(:, 41));
statehousing.V42 = cell2mat(raw(:, 42));
statehousing.V43 = cell2mat(raw(:, 43));
statehousing.V44 = cell2mat(raw(:, 44));
statehousing.V45 = cell2mat(raw(:, 45));
statehousing.V46 = cell2mat(raw(:, 46));
statehousing.V47 = cell2mat(raw(:, 47));
statehousing.V48 = cell2mat(raw(:, 48));
statehousing.V49 = cell2mat(raw(:, 49));
statehousing.V50 = cell2mat(raw(:, 50));
statehousing.V51 = cell2mat(raw(:, 51));
statehousing.V52 = cell2mat(raw(:, 52));
statehousing.V53 = cell2mat(raw(:, 53));
statehousing.V54 = cell2mat(raw(:, 54));
statehousing.V55 = cell2mat(raw(:, 55));
statehousing.V56 = cell2mat(raw(:, 56));
statehousing.V57 = cell2mat(raw(:, 57));
statehousing.V58 = cell2mat(raw(:, 58));
statehousing.V59 = cell2mat(raw(:, 59));
statehousing.V60 = cell2mat(raw(:, 60));
statehousing.V61 = cell2mat(raw(:, 61));
statehousing.V62 = cell2mat(raw(:, 62));
statehousing.V63 = cell2mat(raw(:, 63));
statehousing.V64 = cell2mat(raw(:, 64));
statehousing.V65 = cell2mat(raw(:, 65));
statehousing.V66 = cell2mat(raw(:, 66));
statehousing.V67 = cell2mat(raw(:, 67));
statehousing.V68 = cell2mat(raw(:, 68));
statehousing.V69 = cell2mat(raw(:, 69));
statehousing.V70 = cell2mat(raw(:, 70));
statehousing.V71 = cell2mat(raw(:, 71));
statehousing.V72 = cell2mat(raw(:, 72));
statehousing.V73 = cell2mat(raw(:, 73));
statehousing.V74 = cell2mat(raw(:, 74));
statehousing.V75 = cell2mat(raw(:, 75));
statehousing.V76 = cell2mat(raw(:, 76));
statehousing.V77 = cell2mat(raw(:, 77));
statehousing.V78 = cell2mat(raw(:, 78));
statehousing.V79 = cell2mat(raw(:, 79));
statehousing.V80 = cell2mat(raw(:, 80));
statehousing.V81 = cell2mat(raw(:, 81));
statehousing.V82 = cell2mat(raw(:, 82));
statehousing.V83 = cell2mat(raw(:, 83));
statehousing.V84 = cell2mat(raw(:, 84));
statehousing.V85 = cell2mat(raw(:, 85));
statehousing.V86 = cell2mat(raw(:, 86));
statehousing.V87 = cell2mat(raw(:, 87));
statehousing.V88 = cell2mat(raw(:, 88));
statehousing.V89 = cell2mat(raw(:, 89));
statehousing.V90 = cell2mat(raw(:, 90));
statehousing.V91 = cell2mat(raw(:, 91));
statehousing.V92 = cell2mat(raw(:, 92));
statehousing.V93 = cell2mat(raw(:, 93));
statehousing.V94 = cell2mat(raw(:, 94));
statehousing.V95 = cell2mat(raw(:, 95));
statehousing.V96 = cell2mat(raw(:, 96));
statehousing.V97 = cell2mat(raw(:, 97));
statehousing.V98 = cell2mat(raw(:, 98));
statehousing.V99 = cell2mat(raw(:, 99));
statehousing.V100 = cell2mat(raw(:, 100));
statehousing.V101 = cell2mat(raw(:, 101));
statehousing.V102 = cell2mat(raw(:, 102));
statehousing.V103 = cell2mat(raw(:, 103));
statehousing.V104 = cell2mat(raw(:, 104));
statehousing.V105 = cell2mat(raw(:, 105));
statehousing.V106 = cell2mat(raw(:, 106));
statehousing.V107 = cell2mat(raw(:, 107));
statehousing.V108 = cell2mat(raw(:, 108));
statehousing.V109 = cell2mat(raw(:, 109));
statehousing.V110 = cell2mat(raw(:, 110));
statehousing.V111 = cell2mat(raw(:, 111));
statehousing.V112 = cell2mat(raw(:, 112));
statehousing.V113 = cell2mat(raw(:, 113));
statehousing.V114 = cell2mat(raw(:, 114));
statehousing.V115 = cell2mat(raw(:, 115));
statehousing.V116 = cell2mat(raw(:, 116));
statehousing.V117 = cell2mat(raw(:, 117));
statehousing.V118 = cell2mat(raw(:, 118));
statehousing.V119 = cell2mat(raw(:, 119));
statehousing.V120 = cell2mat(raw(:, 120));
statehousing.V121 = cell2mat(raw(:, 121));
statehousing.V122 = cell2mat(raw(:, 122));
statehousing.V123 = cell2mat(raw(:, 123));
statehousing.V124 = cell2mat(raw(:, 124));
statehousing.V125 = cell2mat(raw(:, 125));
statehousing.V126 = cell2mat(raw(:, 126));
statehousing.V127 = cell2mat(raw(:, 127));
statehousing.V128 = cell2mat(raw(:, 128));
statehousing.V129 = cell2mat(raw(:, 129));
statehousing.V130 = cell2mat(raw(:, 130));
statehousing.V131 = cell2mat(raw(:, 131));
statehousing.V132 = cell2mat(raw(:, 132));
statehousing.V133 = cell2mat(raw(:, 133));
statehousing.V134 = cell2mat(raw(:, 134));
statehousing.V135 = cell2mat(raw(:, 135));
statehousing.V136 = cell2mat(raw(:, 136));
statehousing.V137 = cell2mat(raw(:, 137));
statehousing.V138 = cell2mat(raw(:, 138));
statehousing.V139 = cell2mat(raw(:, 139));
statehousing.V140 = cell2mat(raw(:, 140));
statehousing.V141 = cell2mat(raw(:, 141));
statehousing.V142 = cell2mat(raw(:, 142));
statehousing.V143 = cell2mat(raw(:, 143));
statehousing.V144 = cell2mat(raw(:, 144));
statehousing.V145 = cell2mat(raw(:, 145));
statehousing.V146 = cell2mat(raw(:, 146));
statehousing.V147 = cell2mat(raw(:, 147));
statehousing.V148 = cell2mat(raw(:, 148));
statehousing.V149 = cell2mat(raw(:, 149));
statehousing.V150 = cell2mat(raw(:, 150));
statehousing.V151 = cell2mat(raw(:, 151));
statehousing.V152 = cell2mat(raw(:, 152));
statehousing.V153 = cell2mat(raw(:, 153));
statehousing.V154 = cell2mat(raw(:, 154));
statehousing.V155 = cell2mat(raw(:, 155));
statehousing.V156 = cell2mat(raw(:, 156));
statehousing.V157 = cell2mat(raw(:, 157));
statehousing.V158 = cell2mat(raw(:, 158));
statehousing.V159 = cell2mat(raw(:, 159));
statehousing.V160 = cell2mat(raw(:, 160));
statehousing.V161 = cell2mat(raw(:, 161));
statehousing.V162 = cell2mat(raw(:, 162));
statehousing.V163 = cell2mat(raw(:, 163));
statehousing.V164 = cell2mat(raw(:, 164));
statehousing.V165 = cell2mat(raw(:, 165));
statehousing.V166 = cell2mat(raw(:, 166));
statehousing.V167 = cell2mat(raw(:, 167));
statehousing.V168 = cell2mat(raw(:, 168));
statehousing.V169 = cell2mat(raw(:, 169));
statehousing.V170 = cell2mat(raw(:, 170));
statehousing.V171 = cell2mat(raw(:, 171));
statehousing.V172 = cell2mat(raw(:, 172));
statehousing.V173 = cell2mat(raw(:, 173));
statehousing.V174 = cell2mat(raw(:, 174));
statehousing.V175 = cell2mat(raw(:, 175));
statehousing.V176 = cell2mat(raw(:, 176));
statehousing.V177 = cell2mat(raw(:, 177));
statehousing.V178 = cell2mat(raw(:, 178));
statehousing.V179 = cell2mat(raw(:, 179));
statehousing.V180 = cell2mat(raw(:, 180));
statehousing.V181 = cell2mat(raw(:, 181));
statehousing.V182 = cell2mat(raw(:, 182));
statehousing.V183 = cell2mat(raw(:, 183));
statehousing.V184 = cell2mat(raw(:, 184));
statehousing.V185 = cell2mat(raw(:, 185));
statehousing.V186 = cell2mat(raw(:, 186));
statehousing.V187 = cell2mat(raw(:, 187));
statehousing.V188 = cell2mat(raw(:, 188));
statehousing.V189 = cell2mat(raw(:, 189));
statehousing.V190 = cell2mat(raw(:, 190));
statehousing.V191 = cell2mat(raw(:, 191));
statehousing.V192 = cell2mat(raw(:, 192));
statehousing.V193 = cell2mat(raw(:, 193));
statehousing.V194 = cell2mat(raw(:, 194));
statehousing.V195 = cell2mat(raw(:, 195));
statehousing.V196 = cell2mat(raw(:, 196));
statehousing.V197 = cell2mat(raw(:, 197));
statehousing.V198 = cell2mat(raw(:, 198));
statehousing.V199 = cell2mat(raw(:, 199));
statehousing.V200 = cell2mat(raw(:, 200));
statehousing.V201 = cell2mat(raw(:, 201));
statehousing.V202 = cell2mat(raw(:, 202));
statehousing.V203 = cell2mat(raw(:, 203));
statehousing.V204 = cell2mat(raw(:, 204));
statehousing.V205 = cell2mat(raw(:, 205));
statehousing.V206 = cell2mat(raw(:, 206));
statehousing.V207 = cell2mat(raw(:, 207));
statehousing.V208 = cell2mat(raw(:, 208));
statehousing.V209 = cell2mat(raw(:, 209));
statehousing.V210 = cell2mat(raw(:, 210));
statehousing.V211 = cell2mat(raw(:, 211));
statehousing.V212 = cell2mat(raw(:, 212));
statehousing.V213 = cell2mat(raw(:, 213));
statehousing.V214 = cell2mat(raw(:, 214));
statehousing.V215 = cell2mat(raw(:, 215));
statehousing.V216 = cell2mat(raw(:, 216));
statehousing.V217 = cell2mat(raw(:, 217));
statehousing.V218 = cell2mat(raw(:, 218));
statehousing.V219 = cell2mat(raw(:, 219));
statehousing.V220 = cell2mat(raw(:, 220));
statehousing.V221 = cell2mat(raw(:, 221));
statehousing.V222 = cell2mat(raw(:, 222));
statehousing.V223 = cell2mat(raw(:, 223));
statehousing.V224 = cell2mat(raw(:, 224));
statehousing.V225 = cell2mat(raw(:, 225));
statehousing.V226 = cell2mat(raw(:, 226));
statehousing.V227 = cell2mat(raw(:, 227));
statehousing.V228 = cell2mat(raw(:, 228));
statehousing.V229 = cell2mat(raw(:, 229));
statehousing.V230 = cell2mat(raw(:, 230));
statehousing.V231 = cell2mat(raw(:, 231));
statehousing.V232 = cell2mat(raw(:, 232));
statehousing.V233 = cell2mat(raw(:, 233));
statehousing.V234 = cell2mat(raw(:, 234));
statehousing.V235 = cell2mat(raw(:, 235));
statehousing.V236 = cell2mat(raw(:, 236));
statehousing.V237 = cell2mat(raw(:, 237));
statehousing.V238 = cell2mat(raw(:, 238));
statehousing.V239 = cell2mat(raw(:, 239));
statehousing.V240 = cell2mat(raw(:, 240));
statehousing.V241 = cell2mat(raw(:, 241));
statehousing.V242 = cell2mat(raw(:, 242));
statehousing.V243 = cell2mat(raw(:, 243));
statehousing.V244 = cell2mat(raw(:, 244));
statehousing.V245 = cell2mat(raw(:, 245));
statehousing.V246 = cell2mat(raw(:, 246));
statehousing.V247 = cell2mat(raw(:, 247));
statehousing.V248 = cell2mat(raw(:, 248));
statehousing.V249 = cell2mat(raw(:, 249));
statehousing.V250 = cell2mat(raw(:, 250));
statehousing.V251 = cell2mat(raw(:, 251));
statehousing.V252 = cell2mat(raw(:, 252));
statehousing.V253 = cell2mat(raw(:, 253));
statehousing.V254 = cell2mat(raw(:, 254));
statehousing.V255 = cell2mat(raw(:, 255));
statehousing.V256 = cell2mat(raw(:, 256));
statehousing.V257 = cell2mat(raw(:, 257));
statehousing.V258 = cell2mat(raw(:, 258));
statehousing.V259 = cell2mat(raw(:, 259));
statehousing.V260 = cell2mat(raw(:, 260));
statehousing.V261 = cell2mat(raw(:, 261));
statehousing.V262 = cell2mat(raw(:, 262));
statehousing.V263 = cell2mat(raw(:, 263));
statehousing.V264 = cell2mat(raw(:, 264));
statehousing.V265 = cell2mat(raw(:, 265));
statehousing.V266 = cell2mat(raw(:, 266));
statehousing.V267 = cell2mat(raw(:, 267));
statehousing.V268 = cell2mat(raw(:, 268));
statehousing.V269 = cell2mat(raw(:, 269));
statehousing.V270 = cell2mat(raw(:, 270));
statehousing.V271 = cell2mat(raw(:, 271));
statehousing.V272 = cell2mat(raw(:, 272));
statehousing.V273 = cell2mat(raw(:, 273));
statehousing.V274 = cell2mat(raw(:, 274));
statehousing.V275 = cell2mat(raw(:, 275));

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;