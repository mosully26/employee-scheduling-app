<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import DashboardCard from '$lib/components/DashboardCard.svelte';

  let profile = $state<any>(null);
  let shifts = $state<any[]>([]);
  let announcements = $state<any[]>([]);
  let loading = $state(true);
  let error = $state('');
  let sidebarOpen = $state(false);

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

      profile = Array.isArray(profileData) ? profileData[0] : profileData;

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

      const { data: announcementData } = await supabase
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(3);

      announcements = announcementData ?? [];
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading the dashboard.';
    } finally {
      loading = false;
    }
  });

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString([], {
      weekday: 'short',
      month: 'short',
      day: 'numeric'
    });
  }

  function formatTime(date: string) {
    return new Date(date).toLocaleTimeString([], {
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

<div class="min-h-screen bg-[#fff9f8]">
  <Sidebar profile={profile} bind:isOpen={sidebarOpen} />

  <div class="md:ml-72">
    <div class="sticky top-0 z-20 border-b border-[#efd9dd] bg-white/90 backdrop-blur">
      <div class="flex items-center justify-between px-4 py-4 md:px-6">
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
          <section class="rounded-3xl bg-white p-6 shadow-md">
            <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <div>
                <p class="mb-2 text-sm font-medium uppercase tracking-[0.2em] text-[#b08c8c]">
                  {getGreeting()}
                </p>
                <h1 class="text-3xl font-bold text-[#6b4f4f]">
                  Welcome, {profile?.full_name}
                </h1>
                <p class="mt-1 text-[#9c7b7b]">
                  Unique Beauty Team
                </p>
              </div>

              <div class="rounded-2xl bg-[#fff7f8] px-5 py-4">
                <p class="text-sm text-[#9c7b7b]">Current account</p>
                <p class="font-semibold text-[#6b4f4f]">{profile?.email}</p>
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
                  href="/schedule"
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
                  {#each shifts as shift}
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
                  {#each announcements as item}
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