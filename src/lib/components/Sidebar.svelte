<script lang="ts">
  import { supabase } from '$lib/supabaseClient';

  let {
    profile = null,
    isOpen = $bindable(true)
  }: {
    profile?: {
      full_name?: string;
      role?: string;
      job_title?: string;
      profile_image_url?: string;
    } | null;
    isOpen?: boolean;
  } = $props();

  let pathname = $state('');

  const links = [
    { href: '/dashboard', label: 'Dashboard' },
    { href: '/schedule', label: 'Schedule' },
    { href: '/time-off', label: 'Time Off' },
    { href: '/profile', label: 'Profile' },
    { href: '/admin', label: 'Admin' }
  ];

  function updatePath() {
    if (typeof window !== 'undefined') {
      pathname = window.location.pathname;
    }
  }

  function isActive(path: string) {
    return pathname === path;
  }

  function getInitials(name: string) {
    if (!name) return '?';

    return name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
      .toUpperCase();
  }

  async function logout() {
    await supabase.auth.signOut();
    window.location.href = '/login';
  }

  $effect(() => {
    if (typeof window === 'undefined') return;

    updatePath();

    const onPopState = () => updatePath();
    window.addEventListener('popstate', onPopState);

    return () => {
      window.removeEventListener('popstate', onPopState);
    };
  });
</script>

{#if isOpen}
  <div
    class="fixed inset-0 z-30 bg-black/30 md:hidden"
    aria-hidden="true"
  ></div>
{/if}

<aside
  class={`fixed left-0 top-0 z-40 flex h-screen w-72 flex-col border-r border-[#efd9dd] bg-white transition-transform duration-300 md:translate-x-0 ${
    isOpen ? 'translate-x-0' : '-translate-x-full'
  }`}
>
  <div class="flex items-center justify-between border-b border-[#efd9dd] px-5 py-4">
    <div class="flex items-center gap-3">
      <img
        src="/favicon.png"
        alt="Unique Beauty"
        class="h-11 w-11 rounded-full object-cover"
      />
      <div>
        <p class="text-lg font-bold text-[#6b4f4f]">Unique Beauty</p>
        <p class="text-xs uppercase tracking-[0.22em] text-[#b08c8c]">Scheduler</p>
      </div>
    </div>

    <button
      type="button"
      class="rounded-lg px-2 py-1 text-[#6b4f4f] hover:bg-[#f7edee] md:hidden"
      onclick={() => (isOpen = false)}
    >
      ✕
    </button>
  </div>

  <div class="border-b border-[#efd9dd] px-5 py-5">
    <div class="flex items-center gap-3">
      {#if profile?.profile_image_url}
        <img
          src={profile.profile_image_url}
          alt="Profile"
          class="h-12 w-12 rounded-full object-cover"
        />
      {:else}
        <div
          class="flex h-12 w-12 items-center justify-center rounded-full bg-[#f7edee] text-sm font-bold text-[#6b4f4f]"
        >
          {getInitials(profile?.full_name ?? '')}
        </div>
      {/if}

      <div class="min-w-0">
        <p class="truncate font-semibold text-[#6b4f4f]">
          {profile?.full_name || 'Employee'}
        </p>
      </div>
    </div>
  </div>
  <div class="min-w-0">
    

  <nav class="flex-1 px-4 py-5">
    <div class="space-y-2">
      {#each links as link}
        <a
          href={link.href}
          class={`block rounded-xl px-4 py-3 font-medium transition ${
            isActive(link.href)
              ? 'bg-[#ff2d96] text-white shadow-sm'
              : 'text-[#6b4f4f] hover:bg-[#f7edee]'
          }`}
        >
          {link.label}
        </a>
      {/each}
    </div>
  </nav>

  <div class="border-t border-[#efd9dd] px-4 py-4">
    <button
      type="button"
      onclick={logout}
      class="w-full rounded-xl bg-[#6b4f4f] px-4 py-3 font-medium text-white hover:opacity-90"
    >
      Log Out
    </button>
  </div>
</aside>