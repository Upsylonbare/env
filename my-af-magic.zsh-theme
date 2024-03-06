# af-magic.zsh-theme
#
# Author: Andy Fleming
# URL: http://andyfleming.com/

# dashed separator size
function afmagic_dashes {
  # check either virtualenv or condaenv variables
  local python_env="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"

  # if there is a python virtual environment and it is displayed in
  # the prompt, account for it when returning the number of dashes
  if [[ -n "$python_env" && "$PS1" = \(* ]]; then
    echo $(( COLUMNS - ${#python_env} - 3 ))
  else
    echo $COLUMNS
  fi
}

theme_of_the_day() {
  local today=$(date +'%m-%d')
  local birthday='MM-DD'       # Replace MM-DD with your birthday
  local christmas='12-25'
  local valentines_day='02-14' # Valentine's Day
  local halloween='10-31'     # Halloween
  local earth_day='04-22'     # Earth Day
  local national_day='07-14'  # Bastille Day (French national day)
  local smile_day='10-01'     # World Smile Day
  local april_fools='04-01'   # April Fools' Day
  local pet_day='10-04'       # National Pet Day
  local womens_day='03-08'    # International Women's Day

  if [ "$today" = "$birthday" ]; then
    echo "🎉"  # Emoji for birthday
  elif [ "$today" = "$christmas" ]; then
    echo "🎅"  # Emoji for Christmas
  elif [ "$today" = "$valentines_day" ]; then
    echo "❤️"  # Emoji for Valentine's Day
  elif [ "$today" = "$halloween" ]; then
    echo "🎃"  # Emoji for Halloween
  elif [ "$today" = "$earth_day" ]; then
    echo "🌍"  # Emoji for Earth Day
  elif [ "$today" = "$national_day" ]; then
    echo "🇫🇷"  # French flag emoji for Bastille Day
  elif [ "$today" = "$smile_day" ]; then
    echo "😃"  # Emoji for World Smile Day
  elif [ "$today" = "$april_fools" ]; then
    echo "🤡"  # Emoji for April Fools' Day
  elif [ "$today" = "$pet_day" ]; then
    echo "🐶🐱"  # Emoji for National Pet Day
  elif [ "$today" = "$womens_day" ]; then
    echo "♀️"  # Emoji for International Women's Day
  else
    echo "😃"  # Default emoji
  fi
}

#Rst term prompt every seconds to get live updating clock
#TMOUT=1
#TRAPALRM() {
#    zle reset-prompt
#}

# primary prompt: dashed separator, directory and vcs info
PS1="${FG[237]}\${(l.\$(afmagic_dashes)..-.)}%{$reset_color%}
${FG[039]}%~\$(git_prompt_info)\$(hg_prompt_info) ${FG[105]}%(!.#.»)%{$reset_color%} "
PS2="%{$fg[red]%}\ %{$reset_color%}"

# right prompt: return code, virtualenv and context (user@host)
RPS1="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
if (( $+functions[virtualenv_prompt_info] )); then
  RPS1+='$(virtualenv_prompt_info)'
fi
#RPS1+=" ${FG[237]}%n@%m%{$reset_color%}"
RPS1+="\$(theme_of_the_day) ${FG[105]}%D %*%{$reset_color%} ${FG[160]}%n@%m%{$reset_color%}"

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" ${FG[075]}(${FG[078]}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${FG[075]})%{$reset_color%}"

# hg settings
ZSH_THEME_HG_PROMPT_PREFIX=" ${FG[075]}(${FG[078]}"
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_HG_PROMPT_SUFFIX="${FG[075]})%{$reset_color%}"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[075]}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"

# Tune exa colors:
export EXA_COLORS="di=38;5;033:da=38;5;146"
# For zsh to use colors
export LS_COLORS=${LS_COLORS//di=01;34:/di=38;5;033:}
