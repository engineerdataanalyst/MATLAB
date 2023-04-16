classdef song < document
  % ==
  % ----------------
  % - the song class
  % ----------------
  % ==
  properties (Dependent, SetAccess = private) % song properties
    title;
    artist;
    album;
  end
  % ==
  methods % song constructor
    % ==
    function doc = song(varargin)
      % ----------------------
      % - the song constructor
      % ----------------------
      doc = doc@document(varargin{:});
    end
    % ==
    function title = get.title(doc)
      % -----------------------
      % - gets the song's title
      %   from the text
      % -----------------------
      
      %% find the newline indices
      if isstring(doc.text)
        convert2stringarray = true;
        new_text = char(doc.text);
      else
        convert2stringarray = false;
        new_text = doc.text;
      end
      ind = find(new_text == newline, 1);
      %% get the song's title
      if doc.num_lines < 1
        title = '';
      elseif doc.num_lines == 1
        title = new_text;
      else
        title = new_text(1:ind-1);
      end
      %% convert back to string array if necessary
      if convert2stringarray
        title = string(title);
      end
    end
    % ==
    function artist = get.artist(doc)
      % ------------------------
      % - gets the song's artist
      %   from the text
      % ------------------------
      
      %% find the newline indices
      if isstring(doc.text)
        convert2stringarray = true;
        new_text = char(doc.text);
      else
        convert2stringarray = false;
        new_text = doc.text;
      end
      ind = find(new_text == newline, 2);
      %% get the song's artist
      if doc.num_lines < 2
        artist = '';
      elseif doc.num_lines == 2
        artist = new_text(ind+1:end);
      else
        artist = new_text(ind(1)+1:ind(2)-1);
      end
      %% convert back to string array if necessary
      if convert2stringarray
        artist = string(artist);
      end
    end
    % ==
    function album = get.album(doc)
      % -----------------------
      % - gets the song's album
      %   from the text
      % -----------------------
      
      %% find the newline indices
      if isstring(doc.text)
        convert2stringarray = true;
        new_text = char(doc.text);
      else
        convert2stringarray = false;
        new_text = doc.text;
      end
      ind = find(new_text == newline, 3);
      %% get the song's album
      if doc.num_lines < 3
        album = '';
      elseif doc.num_lines == 3
        album = new_text(ind(2)+1:end);
      else
        album = new_text(ind(2)+1:ind(3)-1);
      end
      %% convert back to string array if necessary
      if convert2stringarray
        album = string(album);
      end
    end
    % ==
  end
end
