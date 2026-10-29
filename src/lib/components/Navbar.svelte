<script lang="ts">
  import { resolve } from '$app/paths';
  import { supabase } from '$lib/supabaseClient';

  let pathname = $state('');

  function updatePath() {
    pathname = window.location.pathname;
  }

  async function logout() {
    await supabase.auth.signOut();
    window.location.href = '/login';
  }

  $effect(() => {
    if (typeof window !== 'undefined') {
      updatePath();
      window.addEventListener('popstate', updatePath);

      return () => {
        window.removeEventListener('popstate', updatePath);
      };
    }
  });

  function linkClasses(path: string) {
    const active = pathname === path;
    return active
      ? 'rounded-lg bg-[#ff2d96] px-4 py-2 text-white'
      : 'rounded-lg px-4 py-2 text-[#6b4f4f] hover:bg-[#f7edee]';
  }
</script>

<nav class="border-b border-[#efd9dd] bg-white/90 backdrop-blur">
  <div class="mx-auto flex max-w-7xl items-center justify-between gap-4 px-6 py-4">
    <div class="flex items-center gap-3">
      <img
        src="/favicon.png"
        alt="Unique Beauty"
        class="h-10 w-10 rounded-full object-cover"
      />
      <div>
        <p class="text-lg font-bold text-[#6b4f4f]">Unique Beauty</p>
        <p class="text-xs uppercase tracking-[0.2em] text-[#b08c8c]">Scheduler</p>
      </div>
    </div>

    <div class="hidden items-center gap-2 md:flex">
      <a href={resolve('/dashboard')} class={linkClasses('/dashboard')}>Dashboard</a>
      <a href={resolve('/schedule')} class={linkClasses('/schedule')}>Schedule</a>
      <a href={resolve('/time-off')} class={linkClasses('/time-off')}>Time Off</a>
      <a href={resolve('/profile')} class={linkClasses('/profile')}>Profile</a>
      <a href={resolve('/admin')} class={linkClasses('/admin')}>Admin</a>
    </div>

    <button
      type="button"
      onclick={logout}
      class="rounded-lg bg-[#6b4f4f] px-4 py-2 text-white hover:opacity-90"
    >
      Log Out
    </button>
  </div>
</nav>