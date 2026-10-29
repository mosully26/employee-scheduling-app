<script lang="ts">
  import { resolve } from '$app/paths';
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';

  let email = $state('');
  let password = $state('');
  let error = $state('');
  let showPassword = $state(false);
  let rememberEmail = $state(true);

  onMount(() => {
    const savedEmail = localStorage.getItem('unique-beauty-saved-email');

    if (savedEmail) {
      email = savedEmail;
    }
  });

  async function login() {
    error = '';

    if (rememberEmail) {
      localStorage.setItem('unique-beauty-saved-email', email);
    } else {
      localStorage.removeItem('unique-beauty-saved-email');
    }

    const { error: loginError } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (loginError) {
      error = loginError.message;
      return;
    }

    window.location.href = '/dashboard';
  }
</script>

<div class="min-h-screen bg-[radial-gradient(circle_at_top,#fff9f8_0%,#f7edee_55%,#f1e4e6_100%)] px-4 py-10">
  <div class="mx-auto flex min-h-[85vh] max-w-md items-center justify-center">
    <div class="w-full rounded-4xl border border-white/70 bg-white/80 p-8 shadow-[0_20px_60px_rgba(107,79,79,0.14)] backdrop-blur">
      <div class="mb-6 flex flex-col items-center text-center">
        <a href={resolve('/')} class="mb-4 transition hover:scale-[1.02]">
          <img
            src="/favicon.png"
            alt="Unique Beauty logo"
            class="h-28 w-28 object-contain md:h-36 md:w-36"          
            />
        </a>

        <h2 class="text-4xl font-bold text-[#6b4f4f]">Login</h2>
        <p class="mt-2 text-[#9c7b7b]">Welcome back to Unique Beauty</p>
        <p class="text-sm text-[#9c7b7b]">Don't have an account? <a href={resolve('/signup')} class="text-[#ff2d96] hover:underline">Create account</a></p>
      </div>

      <div class="space-y-4">
        <input
          bind:value={email}
          type="email"
          autocomplete="email"
          placeholder="Email"
          class="w-full rounded-xl border border-[#efd9dd] bg-white px-4 py-3"
        />

        <div class="relative">
          <input
            bind:value={password}
            type={showPassword ? 'text' : 'password'}
            autocomplete="current-password"
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

        <label class="flex items-center gap-2 text-sm text-[#7d6161]">
          <input bind:checked={rememberEmail} type="checkbox" class="h-4 w-4 accent-[#ff2d96]" />
          Remember my email
        </label>

        {#if error}
          <p class="text-sm text-red-500">{error}</p>
        {/if}

        <button
          type="button"
          onclick={login}
          class="w-full rounded-xl bg-[#6b4f4f] py-3 text-lg font-semibold text-white transition hover:opacity-90"
        >
          Sign In
        </button>
      </div>
    </div>
  </div>
</div>