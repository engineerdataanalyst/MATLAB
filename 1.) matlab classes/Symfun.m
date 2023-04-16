classdef (InferiorClasses = {?sym}) Symfun < symfun
  % ==
  % ----------------------------------------
  % - a slight variation of the symfun class
  % - will allow indexing of symfun objects
  %   by redefining the subsref and subsasgn
  %   functions accordingly
  % ----------------------------------------
  % ==
  methods
    % ==
    function a = Symfun(varargin)
      a = a@symfun(varargin{:});
    end
    % ==
    function n = numel(varargin)
      n = 1;
    end
    % ==
    function varargout = subsref(a, s)
      if length(s) > 2
        error('too many indexing references');
      end
      switch s(1).type
        case '()'
          varargout{1} = subsref@symfun(a, s);
        case '{}'
          varargout{1} = index(a, s(1).subs{:});
          if ~isscalar(s)
            if ~strcmp(s(2).type, '()')
              error('invalid indexing reference');
            end
            varargout{1} = varargout{1}(s(2).subs{:});
          else
            varargout{1} = Symfun.convert2Symfun(varargout{1});
          end
        otherwise
          error('invalid indexing reference');
      end
    end
    % ==
    function varargout = subsasgn(a, s, rhs)
      if ~isscalar(s)
        error('too many indexing assignments');
      end
      switch s.type
        case '()'
          varargout{1} = subsasgn@symfun(a, s, rhs);
          varargout{1} = Symfun.convert2Symfun(varargout{1});
        case '{}'
          s.type = '()';
          varargout{1} = subsasgn@sym(formula(a), s, rhs);
          varargout{1} = Symfun(varargout{1}, argnames(a));
        otherwise
          error('invalid indexing assignment');
      end
    end
    % ==
  end
  % ==
  methods (Static)
    % ==
    function a = convert2Symfun(rhs)
      arguments
        rhs symfun;
      end
      a = Symfun(rhs, argnames(rhs));
    end
    % ==
    function a = convert2symfun(rhs)
      arguments
        rhs Symfun;
      end
      a = symfun(rhs, argnames(rhs));
    end
    % ==
  end
  % ==
end
