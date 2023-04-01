classdef document < matlab.mixin.Copyable & matlab.mixin.CustomDisplay
  % ==
  % --------------------
  % - the document class
  % --------------------
  % ==
  properties % text property
    text {mustBeTextScalar} = '';
  end
  % ==
  properties (Dependent, SetAccess = private) % number of lines property
    num_lines;
  end
  % ==
  properties (SetAccess = private) % parsing tables
    words;
    symbols;
    letters;
  end
  % ==
  properties (Constant) % bad words property
    bad_words = {'fuck'; 'shit'; 'bitch'; 'dick'; 'ass';
                 'pussy'; 'damn'; 'nigger'; 'nigga'};
  end
  % ==
  methods % document constructor
    % ==
    function doc = document(text, parse_doc)
      % --------------------------
      % - the document constructor
      % --------------------------
      
      %% construct the text
      arguments
        text {mustBeTextScalar} = '';
        parse_doc (1,1) logical = false;
      end
      if nargin == 1
        parse_doc = true;
      end
      doc.text = text;
      %% construct the words table
      persistent tbl1;
      if ~istable(tbl1)
        tbl1.count = 0;
        tbl1 = struct2table(tbl1, 'RowNames', {'0'});
        tbl1 = addprop(tbl1, {'s' 'f'}, {'table' 'table'});
        tbl1 = addprop(tbl1, 'num_words', 'variable');
        tbl1.Properties.DimensionNames{1} = 'word';
        tbl1.Properties.CustomProperties.s = {};
        tbl1.Properties.CustomProperties.f = {};
        tbl1.Properties.CustomProperties.num_words = 0;
        tbl1(:,:) = [];
      end
      doc.words = tbl1;
      %% construct the symbols table
      persistent tbl2;
      if ~istable(tbl2)
        tbl2.count = 0;
        tbl2 = struct2table(tbl2, 'RowNames', {'0'});
        tbl2 = addprop(tbl2, 'num_symbols', 'variable');
        tbl2.Properties.DimensionNames{1} = 'symbol';
        tbl2.Properties.CustomProperties.num_symbols = 0;
        tbl2(:,:) = [];
      end
      doc.symbols = tbl2;
      %% construct the letters table
      persistent tbl3;
      if ~istable(tbl3)
        tbl3.upper = zeros(26,1);
        tbl3.lower = zeros(26,1);
        tbl3 = struct2table(tbl3, 'RowNames', num2cell('A':'Z'));
        tbl3 = addprop(tbl3, 'num_letters', 'variable');
        tbl3.Properties.DimensionNames{1} = 'letter';
        tbl3.Properties.CustomProperties.num_letters = [0 0];
      end
      doc.letters = tbl3;
      %% parse the document if requested
      if parse_doc
        doc.parse;
      end
    end
    % ==
    function set.text(doc, text)
      % --------------------------
      % - removes any '\r'
      %   characters from the text
      % --------------------------
      if isstring(text)
        text{1}(text{1} == sprintf('\r')) = [];
      else
        text(text == sprintf('\r')) = [];
      end
      doc.text = text;
    end
    % ==
    function num_lines = get.num_lines(doc)
      % ------------------------
      % - computes the number of
      %   lines in the text
      % ------------------------
      if isempty(doc.text)
        num_lines = 0;
      else
        num_lines = count(doc.text, newline)+1;
      end
    end
    % ==
  end
  % ==
  methods (Sealed, Access = protected) % displaying methods
    % ==
    function displayEmptyObject(doc)
      % --------------------------------
      % - override of the display method
      %   for nicely displaying
      %   an empty document
      % --------------------------------
      empty_str = ['empty ' class(doc) ' array'];
      line = repmat('-', size(empty_str));
      fprintf('%s\n%s\n%s\n\n', line, empty_str, line);
    end
    % ==
    function displayScalarObject(doc)
      % --------------------------------
      % - override of the display method
      %   for nicely displaying
      %   a scalar document
      % --------------------------------
      
      %% compute the heading
      num_str = num2str(doc.num_lines);
      heading = [class(doc) ' with ' num_str ' lines'];
      line = repmat('-', size(heading));
      if doc.num_lines == 1
        heading(end) = [];
        line(end) = [];
      end
      heading = stack(line, heading, line);
      %% print the document
      if isempty(doc.text)
        fprintf('%s\n\n', heading);
      else
        fprintf('%s\n%s\n\n', heading, doc.text);
      end
    end
    % ==
    function displayNonScalarObject(doc)
      % --------------------------------
      % - override of the display method
      %   for nicely displaying
      %   a non-scalar document
      % --------------------------------
      size_cell = num2cell(size(doc));
      doc_str = repmat('%dx', size(size_cell));
      doc_str(end) = [];
      doc_str = [sprintf(doc_str, size_cell{:}) ' ' class(doc) ' array'];
      line = repmat('-', size(doc_str));
      fprintf('%s\n%s\n%s\n\n', line, doc_str, line);
    end
    % ==
  end
  % ==
  methods % parsing methods
    % ==
    function reset(doc, options)
      % ---------------------------
      % - resets the parsing tables
      %   of the document class
      % ---------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        doc;
      end
      arguments
        options.Prop (1,:) ...
        {mustBeText, ...
         mustBeMemberi(options.Prop, ["words" "symbols" "letters"])};
      end
      % check the property option
      if isfield(options, 'Prop')
        Prop = unique(string(lower(options.Prop)), 'stable');
      else
        Prop = ["words" "symbols" "letters"];
      end
      %% case for non-scalar documents
      if isempty(doc)
        return;
      elseif ~isscalar(doc)
        for k = 1:numel(doc)
          doc(k).reset('Prop', Prop);
        end
        return;
      end
      %% reset the parsing tables
      for k = Prop
        switch k
          case "words"
            % reset the words table
            if ~isempty(doc.words)
              doc.words(:,:) = [];
              doc.words.Properties.CustomProperties.s = {};
              doc.words.Properties.CustomProperties.f = {};
              doc.words.Properties.CustomProperties.num_words = 0;
            end
          case "symbols"
            % reset the symbols table
            if ~isempty(doc.symbols)
              doc.symbols(:,:) = [];
              doc.symbols.Properties.CustomProperties.num_symbols = 0;
            end
          case "letters"
            % reset the letters table
            if any(doc.letters{:,:}, 'all')
              doc.letters.upper(doc.letters.upper ~= 0) = 0;
              doc.letters.lower(doc.letters.lower ~= 0) = 0;
              doc.letters.Properties.CustomProperties.num_letters = [0 0];
            end
        end
      end
    end
    % ==
    function parse(doc, options)
      % ------------------------------
      % - parses the document for
      %   the following information:
      % - 1.) number of words
      %   2.) number of symbols
      %   3.) number of letters
      %      (uppercase and lowercase)
      % ------------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        doc;
      end 
      arguments
        options.Prop (1,:) ...
        {mustBeText, ...
         mustBeMemberi(options.Prop, ["words" "symbols" "letters"])};
      end
      % check the property option
      if isfield(options, 'Prop')
        Prop = unique(string(lower(options.Prop)), 'stable');
      else
        Prop = ["words" "symbols" "letters"];
      end
      %% case for non-scalar documents
      if isempty(doc)
        return;
      elseif ~isscalar(doc)
        for k = 1:numel(doc)
          doc(k).parse('Prop', Prop);
        end
        return;
      end
      %% parse the document
      doc.reset('Prop', Prop);
      for k = Prop
        switch k
          case "words"
            % parse the words            
            [words_in_text s f] = regexp(doc.text, '(\w|[-''])*', 'match');
            unique_words = unique(words_in_text, 'stable').';
            if ~isempty(unique_words)
              word.count = zeros(size(unique_words));
              word = struct2table(word, 'RowNames', unique_words);
              doc.words = [doc.words; word];
              Cell = cell(size(unique_words));
              doc.words.Properties.CustomProperties.s = Cell;
              doc.words.Properties.CustomProperties.f = Cell;
            end
            for p = 1:length(unique_words)
              ind = strcmp(words_in_text, unique_words{p});
              doc.words.count(p) = nnz(ind);
              doc.words.Properties.CustomProperties.s{p} = s(ind).';
              doc.words.Properties.CustomProperties.f{p} = f(ind).';
            end
            num = sum(doc.words.count);
            doc.words.Properties.CustomProperties.num_words = num;
          case "symbols"
            % parse the symbols            
            if isstring(doc.text)
              new_text = char(doc.text);
            else
              new_text = doc.text;
            end
            ind = ~isupper(new_text) & ~islower(new_text) & ...
                  ~isspace(new_text);
            symbols_in_text = new_text(ind);
            unique_symbols = num2cell(unique(symbols_in_text, 'stable')).';
            colons = cellfun(@(arg)strcmp(arg, ':'), unique_symbols);
            unique_symbols(colons) = {':_'};
            if ~isempty(unique_symbols)
              symbol.count = zeros(size(unique_symbols));
              symbol = struct2table(symbol, 'RowNames', unique_symbols);
              doc.symbols = [doc.symbols; symbol];
            end
            unique_symbols(colons) = {':'};
            for p = 1:length(unique_symbols)
              ind = symbols_in_text == unique_symbols{p};
              doc.symbols.count(p) = nnz(ind);
            end
            num = sum(doc.symbols.count);
            doc.symbols.Properties.CustomProperties.num_symbols = num;
          case "letters"
            % parse the upper case letters            
            if isstring(doc.text)
              new_text = char(doc.text);
            else
              new_text = doc.text;
            end
            ind = isupper(new_text);
            uppers_in_text = new_text(ind);
            unique_uppers = unique(uppers_in_text, 'stable');
            for p = 1:length(unique_uppers)
              ind = uppers_in_text == unique_uppers(p);
              doc.letters.upper(unique_uppers(p)) = nnz(ind);
            end
            % parse the lower case letters
            ind = islower(new_text);
            lowers_in_text = new_text(ind);
            unique_lowers = unique(lowers_in_text, 'stable');
            for p = 1:length(unique_lowers)
              ind = lowers_in_text == unique_lowers(p);
              doc.letters.lower(upper(unique_lowers(p))) = nnz(ind);
            end
            num = sum(doc.letters{:,:});
            doc.letters.Properties.CustomProperties.num_letters = num;
        end
      end
    end
    % ==
    function [w s f] = find(doc, target, options)
      % ------------------------
      % - returns an array
      %   containg all of the
      %   words in the text
      %   that match a
      %   certain target word
      % - also returns the start
      %   and ending indices of
      %   these words
      % ------------------------
      
      %% check the input arguments
      % check the argument classes
      arguments
        doc;
        target (1,:) {mustBeText};
        options.Mode (1,:) ...
        {mustBeText, ...
         mustBeMemberi(options.Mode, ["matches" "contains"])} = "matches";
        options.IgnoreCase (1,:) ...
        {mustBeNumericOrLogical, mustBeNonempty} = false;
      end
      target = string(target);
      Mode = string(lower(options.Mode));
      IgnoreCase = options.IgnoreCase;
      % check the argument dimensions
      [~, Mode IgnoreCase] = scalar_expand(target, Mode, IgnoreCase);
      if ~isequallen(target, Mode, IgnoreCase)
        str = stack('''Mode'', and ''IgnoreCase''', ...
                    'must have the same length', ...
                    'as ''target'', or be scalars');
        error(str);
      end
      %% case for non-scalar documents
      if isempty(doc)
        [w s f] = deal({}, [], []);
        return;
      elseif ~isscalar(doc)
        [w s f] = deal(cell(size(doc)));
        Args = {'Mode' Mode 'IgnoreCase' IgnoreCase};
        for k = 1:numel(doc)
          [w{k} s{k} f{k}] = doc(k).find(target, Args{:});
        end
        return;
      end
      %% compute the word information from the table
      Doc = copy(doc);
      if isempty(Doc.words)
        Doc.parse('words');
      end
      if isstring(Doc.text)
        [w s f] = deal(string.empty, [], []);
        wt = string(Doc.words.word);
      else
        [w s f] = deal({}, [], []);
        wt = Doc.words.word;
      end
      st = Doc.words.Properties.CustomProperties.s;
      ft = Doc.words.Properties.CustomProperties.f;
      %% find the words in the text matching the target word
      for k = 1:length(target)
        if Mode(k) == "matches"
          ind = matches(wt, target(k), 'IgnoreCase', IgnoreCase(k));
        else
          ind = contains(wt, target(k), 'IgnoreCase', IgnoreCase(k));
        end
        ind = ind & ~ismember(wt, w);
        if any(ind)
          w = [w; wt(ind)];
          s = [s; st(ind)];
          f = [f; ft(ind)];
        end
      end
      %% modify the outputs to a more convenient type
      if iscellscalar(w)
        w = w{1};
        s = s{1};
        f = f{1};
      end
    end
    % ==
    function [w s f] = find_bad_words(doc, options)
      % ------------------------
      % - returns an array
      %   containg all of the
      %   bad words in the text
      % - also returns the start
      %   and ending indices of
      %   these words
      % ------------------------
      
      %% check the input arguments
      arguments
        doc;
        options.Mode ...
        {mustBeTextScalar, ...
         mustBeMemberi(options.Mode, ["matches" "contains"])} = "contains";
        options.IgnoreCase (1,1) logical = true;
      end
      Args = namedargs2cell(options);
      %% find the bad words
      [w s f] = doc.find(document.bad_words, Args{:});
    end
    % ==
    function bool = has_bad_words(doc)
      % --------------------------
      % - returns true if the text
      %   contains bad words
      % --------------------------
      IgnoreCase = {'IgnoreCase' true};
      bool = false(size(doc));
      for k = 1:numel(doc)
        bool(k) = contains(doc(k).text, document.bad_words, IgnoreCase{:});
      end
    end
    % ==
    function varargout = wordcloud(doc, varargin)
      % ----------------------
      % - plots the word cloud
      %   of the document
      % ----------------------
      if ~isscalar(doc)
        error('the document must be a scalar');
      end
      Doc = copy(doc);
      if isempty(Doc.words)
        Doc.parse('words');
      end
      Doc.words = addvars(Doc.words, Doc.words.word, 'Before', 'count');
      varargin = [{Doc.words 'Var1' 'count'} varargin];
      [varargout{1:nargout}] = wordcloud(varargin{:});
    end
    % ==
  end
  % ==
end
