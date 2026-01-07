defmodule PaperTiger.UserAdapter do
  @moduledoc """
  Behavior for resolving user information from billing customers.

  When syncing Stripe data from a database, customer records often have a foreign
  key to a users table. This adapter discovers and extracts user information (name, email)
  from the user record to populate Stripe customer data.

  ## Built-in Adapters

  - `PaperTiger.UserAdapters.AutoDiscover` - Auto-detects common schema patterns
  - Custom adapters - Implement this behavior for custom schemas

  ## Configuration

      # Auto-discovery (default) - tries common patterns
      config :paper_tiger, user_adapter: :auto

      # Custom adapter
      config :paper_tiger, user_adapter: MyApp.CustomUserAdapter

  ## Implementing a Custom Adapter

      defmodule MyApp.CustomUserAdapter do
        @behaviour PaperTiger.UserAdapter

        @impl true
        def get_user_info(repo, user_id) do
          user = repo.get!(MyApp.User, user_id)

          {:ok, %{
            name: "\#{user.first_name} \#{user.last_name}",
            email: user.email
          }}
        rescue
          _ -> {:error, :user_not_found}
        end
      end

  ## User Info Format

  The adapter should return a map with:
  - `:name` - Full name of the user (optional)
  - `:email` - Email address (optional but recommended)

  If a user cannot be found or an error occurs, return `{:error, reason}`.
  """

  @doc """
  Retrieves user information for a given user ID.

  ## Parameters
  - `repo` - The Ecto.Repo module to query
  - `user_id` - The user's primary key

  ## Returns
  - `{:ok, %{name: String.t(), email: String.t()}}` on success
  - `{:error, term()}` on failure
  """
  @callback get_user_info(repo :: module(), user_id :: term()) ::
              {:ok, %{optional(:email) => String.t(), optional(:name) => String.t()}}
              | {:error, term()}
end
