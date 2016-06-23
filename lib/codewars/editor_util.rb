module Codewars
  class EditorUtil
    def initialize
      @editor = ENV['EDITOR'] || 'vim'
    end

    def self.open(kata, replace: :none)
      code_file = Codewars::FileUtil.get_code_file(kata)
      description_file = Codewars::FileUtil.get_description_file(kata)
      test_file = Codewars::FileUtil.get_test_file(kata)
      system('vim', '-c', vim_script(code_file, description_file, test_file, kata))
    end

    private
    def self.vim_script(code_file, description_file, test_file, kata)
      return <<-VIMSCRIPT
;;
:e #{code_file}
:split #{test_file}
:wincmd r
:wincmd k
:vs|view #{description_file}
:set nomodifiable
:res 30
:wincmd j
:wincmd j
:res 10
:wincmd k
:wincmd l
:30winc >
:map <Leader>q :xall<enter>
:unmap <Leader>t
:map <Leader>t :call Codewars("test")<enter>
:map <Leader>a :call Codewars("attempt")<enter>
:map <Leader>f :call Codewars("finalize")<enter>
:function Codewars(cmd)
  if a:cmd == "test"
    :wall
    :!ruby -I#{File.dirname(Codewars::configuration.file_path)} #{test_file}
  elseif a:cmd == "attempt"
    :wall
    :!codewars attempt #{kata.slug}
  elseif a:cmd == "finalize"
    :wall
    :!codewars finalize #{kata.slug}
  endif
:endfunction
      VIMSCRIPT
    end
  end
end
