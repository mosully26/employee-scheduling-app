<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  let full_name = $state('');
  let email = $state('');
  let password = $state('');
  let error = $state('');
  let loading = $state(false);
  let showPassword = $state(false);

  async function signup() {
    error = '';
    loading = true;

    try {
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password
      });

      console.log('signUp result:', data, signUpError);

      if (signUpError) {
        error = signUpError.message;
        return;
      }

      const user = data.user;

      if (!user) {
        error = 'User was not created.';
        return;
      }

      const { error: profileError } = await supabase.from('profiles').insert([
        {
          id: user.id,
          full_name,
          email,
          role: 'EMPLOYEE'
        }
      ]);

      if (profileError) {
        error = profileError.message;
        return;
      }

      window.location.href = '/';
    } catch (err) {
      console.error(err);
      error = 'Something went wrong during signup.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-[radial-gradient(circle_at_top,_#fff9f8_0%,_#f7edee_55%,_#f1e4e6_100%)] px-4 py-10">
  <div class="mx-auto flex min-h-[85vh] max-w-md items-center justify-center">
    <div class="w-full rounded-[2rem] border border-white/70 bg-white/80 p-8 shadow-[0_20px_60px_rgba(107,79,79,0.14)] backdrop-blur">
      <div class="mb-6 flex flex-col items-center text-center">
        <a href="/" class="mb-4 transition hover:scale-[1.02]">
          <img
            src="/favicon.png"
            alt="Unique Beauty logo"
            class="h-28 w-28 object-contain md:h-36 md:w-36"          
            />
        </a>

        <h2 class="text-4xl font-bold text-[#6b4f4f]">Create Account</h2>
        <p class="mt-2 text-[#9c7b7b]">Join Unique Beauty</p>
        <p class="text-sm text-[#9c7b7b]">Already have an account? <a href="/login" class="text-[#ff2d96] hover:underline">Sign in</a></p>
      </div>

      <div class="space-y-4">
        <input
          bind:value={full_name}
          type="text"
          placeholder="Full Name"
          class="w-full rounded-xl border border-[#efd9dd] bg-white px-4 py-3"
        />

        <input
          bind:value={email}
          type="email"
          placeholder="Email"
          class="w-full rounded-xl border border-[#efd9dd] bg-white px-4 py-3"
        />

        <div class="relative">
          <input
            bind:value={password}
            type={showPassword ? 'text' : 'password'}
            placeholder="Password"
            class="w-full rounded-xl border border-[#efd9dd] bg-white px-4 py-3 pr-12"
          />
          <button
            type="button"
            onclick={() => showPassword = !showPassword}
            class="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-[#9c7b7b] hover:text-[#6b4f4f]"
          >
            {showPassword ? 'Hide' : 'Show'}
          </button>
        </div>

        {#if error}
          <p class="text-sm text-red-500">{error}</p>
        {/if}

        <button
          type="button"
          onclick={signup}
          disabled={loading}
          class="w-full rounded-xl bg-[#6b4f4f] py-3 text-lg font-semibold text-white transition hover:opacity-90 disabled:opacity-50"
        >
          {#if loading}
            Creating account...
          {:else}
            Sign Up
          {/if}
        </button>
      </div>
    </div>
  </div>
</div>