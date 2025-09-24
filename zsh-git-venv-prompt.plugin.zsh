# ~/.zsh/plugins/git-venv-prompt/git-venv-prompt.plugin.zsh

# Check if zsh-async is available (optional for async git updates)
if ! type async_init &>/dev/null; then
    # zsh-async not available, will use synchronous git updates
    _zgvp_async_available=false
else
    _zgvp_async_available=true
fi

setopt PROMPT_SUBST  # Enable command substitution

export VIRTUAL_ENV_DISABLE_PROMPT=1 # Disable default virtualenv prompt

# Function to display virtual environment at the beginning of the second line
function virtualenv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]] && [[ -d "$VIRTUAL_ENV" ]] && [[ "$PATH" == *"$VIRTUAL_ENV"* ]]; then
        echo "%F{yellow}($(basename $VIRTUAL_ENV))%f "
    else
        echo ""
    fi
}

# Git prompt (async using zsh-async)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' check-for-staged-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' untrackedstr '?'
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f %F{red}%u%c%m%f'
zstyle ':vcs_info:git:*' actionformats '%F{cyan}(%b|%a)%f %F{red}%u%c%m%f'

# Hook to check for untracked files
+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
       git status --porcelain | grep -q '^??'; then
        hook_com[misc]='?'
    fi
}
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# Use namespaced global variable to avoid conflicts
_zgvp_git_info=""

# Allow users to customize symbols
: ${ZGVP_DEFAULT_SYMBOL:=">"}
: ${ZGVP_INSERT_SYMBOL:=">"}
: ${ZGVP_NORMAL_SYMBOL:="<"}
: ${ZGVP_VISUAL_SYMBOL:="<"}
: ${ZGVP_REPLACE_SYMBOL:="<"}

# If user didn't set INSERT_SYMBOL, use DEFAULT_SYMBOL
if [[ "$ZGVP_INSERT_SYMBOL" == ">" && "$ZGVP_DEFAULT_SYMBOL" != ">" ]]; then
    ZGVP_INSERT_SYMBOL="$ZGVP_DEFAULT_SYMBOL"
fi

function _zgvp_update_git_info {
    # Force vcs_info to check for changes including untracked files
    vcs_info
    _zgvp_git_info="$vcs_info_msg_0_"
    # Only reset prompt if in interactive shell with ZLE available
    [[ -n "$ZLE_VERSION" ]] && zle && zle reset-prompt
}

# Callback handler for async git updates
function _zgvp_async_callback {
    _zgvp_update_git_info
}

# Start async worker for Git
function _zgvp_async_git_info {
    # Only flush if there are pending jobs to avoid unnecessary calls
    async_job git_worker vcs_info
}

# Initialize the async job or fallback to sync mode
_zgvp_use_async=false
if [[ "$_zgvp_async_available" == "true" ]] && async_init; then
    async_start_worker git_worker
    async_register_callback git_worker _zgvp_async_callback
    _zgvp_use_async=true
elif [[ "$_zgvp_async_available" == "false" ]]; then
    echo "Warning: zsh-async not available, using synchronous git status updates"
else
    echo "Warning: Failed to initialize async worker for git status"
fi

# Ensure Git info updates when changing directories or switching branches
function chpwd {
    # Always do synchronous update first for immediate feedback
    _zgvp_update_git_info
    # Then schedule async update if available
    if [[ "$_zgvp_use_async" == "true" ]]; then
        _zgvp_async_git_info
    fi
}

# Add a hook to update the prompt when the branch changes
function precmd {
    # Always do a synchronous update to catch branch changes immediately
    _zgvp_update_git_info
    # Then schedule async update for any additional changes if available
    if [[ "$_zgvp_use_async" == "true" ]]; then
        _zgvp_async_git_info
    fi
}

# Global variable to hold current mode symbol
_zgvp_current_symbol="$ZGVP_INSERT_SYMBOL"

# Function to set up the prompt (used with or without vi-mode)
function _zgvp_setup_prompt {
    _zgvp_current_symbol="${1:-$ZGVP_INSERT_SYMBOL}"
    
    # Configure two-line prompt
    PROMPT='%F{green}%n@%m%f %F{blue}%(3~|.../%2~|%~)%f $_zgvp_git_info
$(virtualenv_prompt)$_zgvp_current_symbol '

    # RPROMPT to show time aligned to first row
    # RPROMPT='%F{yellow}$(date +"%H:%M")%f'
}

# Function to update prompt based on current mode
function _zgvp_update_mode_symbol {
    local mode_symbol
    
    # Check if zsh-vi-mode plugin is available
    if [[ -n "$ZVM_MODE" ]]; then
        # Using zsh-vi-mode plugin
        case $ZVM_MODE in
            $ZVM_MODE_NORMAL)
                mode_symbol="$ZGVP_NORMAL_SYMBOL"
                ;;
            $ZVM_MODE_INSERT)
                mode_symbol="$ZGVP_INSERT_SYMBOL"
                ;;
            $ZVM_MODE_VISUAL|$ZVM_MODE_VISUAL_LINE)
                mode_symbol="$ZGVP_VISUAL_SYMBOL"
                ;;
            $ZVM_MODE_REPLACE)
                mode_symbol="$ZGVP_REPLACE_SYMBOL"
                ;;
            *)
                mode_symbol="$ZGVP_INSERT_SYMBOL"
                ;;
        esac
    elif [[ "$KEYMAP" == "vicmd" ]]; then
        # Built-in vi-mode normal mode
        mode_symbol="$ZGVP_NORMAL_SYMBOL"
    else
        # Insert mode or emacs mode
        mode_symbol="$ZGVP_INSERT_SYMBOL"
    fi
    
    _zgvp_setup_prompt "$mode_symbol"
}

# Check if zsh-vi-mode plugin is available
if (( $+functions[zvm_after_select_vi_mode] )); then
    # zsh-vi-mode plugin integration
    function zvm_after_select_vi_mode {
        _zgvp_update_mode_symbol
        
        # Force prompt refresh to update mode indicator
        if [[ -n "$ZLE_VERSION" ]]; then
            zle && zle reset-prompt
        fi
    }
    
    # Initialize with zsh-vi-mode
    zvm_after_select_vi_mode
else
    # Set up built-in vi-mode support
    function zle-keymap-select {
        _zgvp_update_mode_symbol
        zle reset-prompt
    }
    zle -N zle-keymap-select
    
    function zle-line-init {
        # Initialize with insert mode
        _zgvp_update_mode_symbol
    }
    zle -N zle-line-init
    
    # Initial setup
    _zgvp_update_mode_symbol
fi

# Initial Git info update - always do synchronous first to ensure hooks are loaded
_zgvp_update_git_info
