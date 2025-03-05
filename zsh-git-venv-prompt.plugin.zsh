# ~/.zsh/plugins/git-venv-prompt/git-venv-prompt.plugin.zsh

# Ensure zsh-async is loaded
if ! type async_init &>/dev/null; then
    echo "Error: zsh-async is required but not found. Please install zsh-async."
    return 1
fi

setopt PROMPT_SUBST  # Enable command substitution

# Function to display virtual environment at the beginning of the second line
function virtualenv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "%F{yellow}($(basename $VIRTUAL_ENV))%f "
    else
        echo ""
    fi
}

# Git prompt (async using zsh-async)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' cleanstr '✔'
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f %F{red}%u%c%f %F{yellow}%m%f'

git_info=""

function _update_git_info {
    vcs_info
    git_info="$vcs_info_msg_0_"
    zle reset-prompt  # Refresh prompt after async update
}

# Start async worker for Git
function async_git_info {
    async_flush_jobs git_worker  # Stop any previous job
    async_job git_worker vcs_info  # Start a new job
}

# Initialize the async job
async_init
async_start_worker git_worker
async_register_callback git_worker _update_git_info

# Ensure Git info updates when changing directories or switching branches
function chpwd {
    async_git_info
}

# Add a hook to update the prompt when the branch changes
function precmd {
    async_git_info
}

# The plugin will auto execute this zvm_after_select_vi_mode function
function zvm_after_select_vi_mode {
    case $ZVM_MODE in
        $ZVM_MODE_NORMAL)
            MODE_SYMBOL="<"
            ;;
        $ZVM_MODE_INSERT)
            MODE_SYMBOL=">"
            ;;
        $ZVM_MODE_VISUAL)
            MODE_SYMBOL="<"
            ;;
        $ZVM_MODE_VISUAL_LINE)
            MODE_SYMBOL="<"
            ;;
        $ZVM_MODE_REPLACE)
            MODE_SYMBOL="<"
            ;;
    esac

    # Configure two-line prompt
    PROMPT='%F{green}%n@%m%f %F{blue}%(3~|.../%2~|%~)%f $git_info
$(virtualenv_prompt)${MODE_SYMBOL} '

    # RPROMPT to show time aligned to first row
    RPROMPT='%F{yellow}$(date +"%H:%M")%f'
}

MODE_SYMBOL=">"

# Configure two-line prompt
PROMPT='%F{green}%n@%m%f %F{blue}%(3~|.../%2~|%~)%f $git_info
$(virtualenv_prompt)${MODE_SYMBOL} '

# RPROMPT to show time aligned to first row
RPROMPT='%F{yellow}$(date +"%H:%M")%f'

# Initial Git info update
async_git_info