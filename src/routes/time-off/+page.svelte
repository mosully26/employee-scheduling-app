<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';
  import TimeOffForm from '$lib/components/TimeOffForm.svelte';

  let profile = $state<any>(null);
  let start_date = $state('');
  let end_date = $state('');
  let reason = $state('');
  let error = $state('');
  let success = $state('');
  let loading = $state(true);
  let submitting = $state(false);
  let requestsLoading = $state(true);
  let requests = $state<any[]>([]);
  let sidebarOpen = $state(false);

  onMount(async () => {
    await initializePage();
  });

  async function initializePage() {
    loading = true;
    error = '';

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
      await loadRequests(user.id);
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading the page.';
    } finally {
      loading = false;
    }
  }

  async function loadRequests(userId?: string) {
    requestsLoading = true;

    try {
      let employeeId = userId;

      if (!employeeId) {
        const {
          data: { user }
        } = await supabase.auth.getUser();

        employeeId = user?.id;
      }

      if (!employeeId) return;

      const { data, error: requestError } = await supabase
        .from('time_off_requests')
        .select('*')
        .eq('employee_id', employeeId)
        .order('created_at', { ascending: false });

      if (requestError) {
        error = requestError.message;
        return;
      }

      requests = data ?? [];
    } catch (err) {
      console.error(err);
      error = 'Something went wrong loading your requests.';
    } finally {
      requestsLoading = false;
    }
  }

  async function submitTimeOff() {
    error = '';
    success = '';
    submitting = true;

    try {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!user) {
        window.location.href = '/login';
        return;
      }

      if (!start_date || !end_date) {
        error = 'Please select both a start date and end date.';
        return;
      }

      if (end_date < start_date) {
        error = 'End date cannot be before the start date.';
        return;
      }

      const { error: insertError } = await supabase.from('time_off_requests').insert([
        {
          employee_id: user.id,
          start_date,
          end_date,
          reason
        }
      ]);

      if (insertError) {
        error = insertError.message;
        return;
      }

      success = 'Time-off request submitted.';
      start_date = '';
      end_date = '';
      reason = '';

      await loadRequests(user.id);
    } catch (err) {
      console.error(err);
      error = 'Something went wrong submitting your request.';
    } finally {
      submitting = false;
    }
  }

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString([], {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  }

  function statusClasses(status: string) {
    if (status === 'APPROVED') return 'bg-green-100 text-green-700';
    if (status === 'DENIED') return 'bg-red-100 text-red-700';
    return 'bg-yellow-100 text-yellow-700';
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
            <p class="text-lg font-bold text-[#6b4f4f]">Time Off</p>
            <p class="text-sm text-[#9c7b7b]">Submit and track time-off requests</p>
          </div>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-2xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading page...</p>
        </div>
      {:else}
        <div class="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
          <div class="rounded-3xl bg-white p-6 shadow-md">
            <TimeOffForm
              bind:start_date
              bind:end_date
              bind:reason
              loading={submitting}
              onsubmit={submitTimeOff}
            />

            {#if error}
              <p class="mt-4 text-sm text-red-500">{error}</p>
            {/if}

            {#if success}
              <p class="mt-4 text-sm text-green-600">{success}</p>
            {/if}
          </div>

          <div class="rounded-3xl bg-white p-6 shadow-md">
            <div class="mb-5">
              <h2 class="text-2xl font-bold text-[#6b4f4f]">My Requests</h2>
              <p class="text-sm text-[#9c7b7b]">View the status of your submitted requests</p>
            </div>

            {#if requestsLoading}
              <p class="text-[#9c7b7b]">Loading requests...</p>
            {:else if requests.length === 0}
              <div class="rounded-2xl border border-dashed border-[#efd9dd] p-6 text-center">
                <p class="text-[#9c7b7b]">No requests submitted yet.</p>
              </div>
            {:else}
              <div class="space-y-4">
                {#each requests as request}
                  <div class="rounded-2xl border border-[#ead8d8] p-4">
                    <div class="mb-2 flex items-center justify-between gap-3">
                      <p class="font-semibold text-[#6b4f4f]">
                        {formatDate(request.start_date)} - {formatDate(request.end_date)}
                      </p>

                      <span
                        class={`rounded-full px-3 py-1 text-xs font-semibold ${statusClasses(request.status)}`}
                      >
                        {request.status}
                      </span>
                    </div>

                    {#if request.reason}
                      <p class="text-sm text-[#7d6161]">{request.reason}</p>
                    {/if}
                  </div>
                {/each}
              </div>
            {/if}
          </div>
        </div>
      {/if}
    </main>
  </div>
</div>