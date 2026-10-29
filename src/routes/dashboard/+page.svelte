<script lang="ts">
  import { resolve } from '$app/paths';
  import { browser } from '$app/environment';
  import { supabase } from '$lib/supabaseClient';
  import { onDestroy, onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import DashboardCard from '$lib/components/DashboardCard.svelte';

  type Profile = {
    id?: string;
    full_name?: string;
    email?: string;
    role?: string;
    profile_image_url?: string;
    job_title?: string;
  };

  type Shift = {
    id?: string | number;
    title?: string;
    start_time?: string;
    end_time?: string;
    shift_role?: string | null;
    notes?: string | null;
    color?: string | null;
  };

  type Announcement = {
    id?: string | number;
    title?: string;
    message?: string;
    created_at?: string;
  };

  let profile = $state<Profile | null>(null);
  let shifts = $state<Shift[]>([]);
  let announcements = $state<Announcement[]>([]);
  let loading = $state(true);
  let error = $state('');
  let sidebarOpen = $state(false);

  async function loadAnnouncements() {
    const { data: announcementData, error: announcementError } = await supabase
      .from('announcements')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(3);

    if (announcementError) {
      error = announcementError.message;
      return;
    }

    announcements = announcementData ?? [];
  }

  function refreshAnnouncements() {
    void loadAnnouncements();
  }

  function refreshAnnouncementsWhenVisible() {
    if (document.visibilityState === 'visible') refreshAnnouncements();
  }

  onDestroy(() => {
    if (!browser) return;

    window.removeEventListener('focus', refreshAnnouncements);
    window.removeEventListener('pageshow', refreshAnnouncements);
    document.removeEventListener('visibilitychange', refreshAnnouncementsWhenVisible);
  });

  onMount(async () => {
    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id);

      if (profileError) {
        error = profileError.message;
        return;
      }

      const profileRecord = Array.isArray(profileData) ? profileData[0] : profileData;
      profile = profileRecord
        ? {
            ...profileRecord,
            full_name: profileRecord.full_name ?? undefined,
            email: profileRecord.email ?? undefined,
            role: profileRecord.role ?? undefined,
            profile_image_url: profileRecord.profile_image_url ?? undefined,
            job_title: profileRecord.job_title ?? undefined
          }
        : null;

      const { data: shiftData, error: shiftError } = await supabase
        .from('shifts')
        .select('*')
        .eq('employee_id', user.id)
        .gte('start_time', new Date().toISOString())
        .order('start_time', { ascending: true })
        .limit(5);

      if (shiftError) {
        error = shiftError.message;
        return;
      }

      shifts = shiftData ?? [];

      await loadAnnouncements();

      window.addEventListener('focus', refreshAnnouncements);
      window.addEventListener('pageshow', refreshAnnouncements);
      document.addEventListener('visibilitychange', refreshAnnouncementsWhenVisible);
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading the dashboard.';
    } finally {
      loading = false;
    }
  });

  function formatDate(date?: string) {
    const value = date ? new Date(date) : new Date();
    return value.toLocaleDateString([], {
      weekday: 'short',
      month: 'short',
      day: 'numeric'
    });
  }

  function formatTime(date?: string) {
    const value = date ? new Date(date) : new Date();
    return value.toLocaleTimeString([], {
      hour: 'numeric',
      minute: '2-digit'
    });
  }

  function getGreeting() {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
</script>

<div class="min-h-screen bg-[linear-gradient(135deg,#fffaf9_0%,#fbf3f4_100%)]">
  <Sidebar
    profile={profile
      ? {
          full_name: profile.full_name ?? undefined,
          role: profile.role ?? undefined,
          job_title: profile.job_title ?? undefined,
          profile_image_url: profile.profile_image_url ?? undefined
        }
      : null}
    bind:isOpen={sidebarOpen}
  />

  <div class="md:ml-72">
    <div class="sticky top-0 z-20 border-b border-[#ead8da]/80 bg-white/85 backdrop-blur-xl">
      <div class="flex items-center justify-between px-4 py-3 md:px-6 md:py-4">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="rounded-lg bg-[#f7edee] px-3 py-2 text-[#6b4f4f] md:hidden"
            onclick={() => (sidebarOpen = true)}
          >
            Menu
          </button>

          <div>
            <p class="text-lg font-bold text-[#6b4f4f]">Dashboard</p>
            <p class="text-sm text-[#9c7b7b]">Unique Beauty employee portal</p>
          </div>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading dashboard...</p>
        </div>
      {:else if error}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-red-500">{error}</p>
        </div>
      {:else}
        <div class="space-y-6">
          <section class="overflow-hidden rounded-3xl bg-white shadow-[0_18px_50px_rgba(107,79,79,0.10)]">
            <div class="grid min-h-72 lg:grid-cols-[1fr_420px]">
              <div class="relative flex items-center p-6 md:p-8">
                <div class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_left_top,rgba(255,45,150,0.09),transparent_42%)]"></div>
                <div class="relative">
                  <p class="mb-3 text-xs font-bold uppercase tracking-[0.22em] text-[#d94a8a]">
                    {getGreeting()}
                  </p>
                  <h1 class="max-w-xl text-3xl font-bold tracking-tight text-[#5f4747] md:text-4xl">
                    Welcome back, {profile?.full_name || 'Team Member'}
                  </h1>
                  <p class="mt-3 max-w-lg text-sm leading-6 text-[#927777] md:text-base">
                    Here is everything you need for a clear and productive day at Unique Beauty.
                  </p>
                  <a
                    href={resolve('/schedule')}
                    class="mt-5 inline-flex rounded-xl bg-[#6b4f4f] px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:-translate-y-0.5 hover:bg-[#5e4343]"
                  >
                    View my schedule
                  </a>
                </div>
              </div>

              <div class="relative min-h-64 overflow-hidden bg-[#f7edee] lg:min-h-full">
                <img
                  src="/unique-beauty-storefront.png"
                  alt="Unique Beauty store"
                  class="absolute inset-0 h-full w-full object-cover"
                />
                <div class="absolute inset-x-0 bottom-0 h-1/3 bg-linear-to-t from-black/35 to-transparent"></div>
                <div class="absolute bottom-5 left-5 text-white">
                  <p class="text-xs font-bold uppercase tracking-[0.18em] text-white/80">Unique Beauty</p>
                  <p class="mt-1 text-lg font-semibold">Your team workplace</p>
                </div>
              </div>
            </div>
          </section>

          <section class="grid gap-4 md:grid-cols-3">
            <DashboardCard
              title="Upcoming Shifts"
              value={shifts.length}
              subtitle="Next scheduled workdays"
              accent="#FF2D96"
            />
            <DashboardCard
              title="Announcements"
              value={announcements.length}
              subtitle="Recent updates from management"
              accent="#D4A13A"
            />
            <DashboardCard
              title="Role"
              value={profile?.role || 'EMPLOYEE'}
              subtitle="Current access level"
              accent="#6B4F4F"
            />
          </section>

          <section class="grid gap-6 xl:grid-cols-[1.15fr_0.85fr]">
            <div class="rounded-3xl bg-white p-6 shadow-md">
              <div class="mb-5 flex items-center justify-between">
                <div>
                  <h2 class="text-2xl font-bold text-[#6b4f4f]">Upcoming Shifts</h2>
                  <p class="text-sm text-[#9c7b7b]">Your next scheduled work times</p>
                </div>

                <a
                  href={resolve('/schedule')}
                  class="rounded-xl bg-[#f7edee] px-4 py-2 text-sm font-medium text-[#6b4f4f] hover:opacity-90"
                >
                  View full schedule
                </a>
              </div>

              {#if shifts.length === 0}
                <div class="rounded-2xl border border-dashed border-[#efd9dd] p-6 text-center">
                  <p class="text-[#9c7b7b]">No shifts scheduled yet.</p>
                </div>
              {:else}
                <div class="space-y-4">
                  {#each shifts as shift, index (shift.id ?? `${shift.title ?? 'shift'}-${index}`)}
                    <div
                      class="rounded-2xl border border-[#ead8d8] p-4"
                      style={`border-left: 6px solid ${shift.color || '#FF2D96'}`}
                    >
                      <div class="flex flex-col gap-2 md:flex-row md:items-start md:justify-between">
                        <div>
                          <h3 class="font-semibold text-[#6b4f4f]">{shift.title}</h3>
                          <p class="text-sm text-[#9c7b7b]">
                            {formatDate(shift.start_time)}
                          </p>
                        </div>

                        <div class="text-sm font-medium text-[#7d6161]">
                          {formatTime(shift.start_time)} - {formatTime(shift.end_time)}
                        </div>
                      </div>

                      {#if shift.shift_role}
                        <p class="mt-2 text-sm text-[#7d6161]">Role: {shift.shift_role}</p>
                      {/if}

                      {#if shift.notes}
                        <p class="mt-1 text-sm text-[#7d6161]">{shift.notes}</p>
                      {/if}
                    </div>
                  {/each}
                </div>
              {/if}
            </div>

            <div class="rounded-3xl bg-white p-6 shadow-md">
              <div class="mb-5">
                <h2 class="text-2xl font-bold text-[#6b4f4f]">Announcements</h2>
                <p class="text-sm text-[#9c7b7b]">Stay updated with Unique Beauty</p>
              </div>

              {#if announcements.length === 0}
                <div class="rounded-2xl border border-dashed border-[#efd9dd] p-6 text-center">
                  <p class="text-[#9c7b7b]">No announcements yet.</p>
                </div>
              {:else}
                <div class="space-y-4">
                  {#each announcements as item, index (item.id ?? `${item.title ?? 'announcement'}-${index}`)}
                    <div class="rounded-2xl bg-[#fff7f8] p-4">
                      <h3 class="font-semibold text-[#6b4f4f]">{item.title}</h3>
                      <p class="mt-2 text-sm text-[#7d6161]">{item.message}</p>
                    </div>
                  {/each}
                </div>
              {/if}
            </div>
          </section>
        </div>
      {/if}
    </main>
  </div>
</div>