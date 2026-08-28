<script lang="ts">
  import { supabase } from '$lib/supabaseClient';
  import { onMount } from 'svelte';
  import Sidebar from '$lib/components/Sidebar.svelte';

  type Profile = {
    id?: string;
    email?: string;
    full_name?: string;
    role?: string;
    job_title?: string;
    phone?: string;
    profile_image_url?: string;
  } | null;

  let profile = $state<Profile>(null);

  let full_name = $state('');
  let job_title = $state('');
  let phone = $state('');
  let profile_image_url = $state('');

  let loading = $state(true);
  let saving = $state(false);
  let error = $state('');
  let success = $state('');
  let sidebarOpen = $state(false);

  let fileInput: HTMLInputElement | undefined;

  onMount(async () => {
    await loadProfile();
  });

  async function loadProfile() {
  loading = true;
  error = '';
  success = '';

  try {
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      window.location.href = '/login';
      return;
    }

    const { data, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError) {
      error = profileError.message;
      return;
    }

    if (!data) {
      const newProfile = {
        id: user.id,
        email: user.email,
        full_name: '',
        job_title: '',
        phone: '',
        profile_image_url: ''
      };

      const { data: insertedProfile, error: insertError } = await supabase
        .from('profiles')
        .insert([newProfile])
        .select()
        .maybeSingle();

      if (insertError) {
        error = insertError.message;
        return;
      }

      profile = insertedProfile;
      full_name = insertedProfile?.full_name ?? '';
      job_title = insertedProfile?.job_title ?? '';
      phone = insertedProfile?.phone ?? '';
      profile_image_url = insertedProfile?.profile_image_url ?? '';
      return;
    }

    profile = data;
    full_name = data.full_name ?? '';
    job_title = data.job_title ?? '';
    phone = data.phone ?? '';
    profile_image_url = data.profile_image_url ?? '';
  } catch (err) {
    console.error(err);
    error = 'Something went wrong loading your profile.';
  } finally {
    loading = false;
  }
}
  async function saveProfile() {
  error = '';
  success = '';
  saving = true;

  try {
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      window.location.href = '/login';
      return;
    }

    const { data, error: updateError } = await supabase
      .from('profiles')
      .update({
        full_name: full_name.trim(),
        job_title: job_title.trim(),
        phone: phone.trim(),
        profile_image_url
      })
      .eq('id', user.id)
      .select()
      .maybeSingle();

    if (updateError) {
      error = updateError.message;
      return;
    }

    profile = data;
    full_name = data?.full_name ?? '';
    job_title = data?.job_title ?? '';
    phone = data?.phone ?? '';
    profile_image_url = data?.profile_image_url ?? '';

    success = 'Profile updated successfully.';
  } catch (err) {
    console.error(err);
    error = 'Something went wrong saving your profile.';
  } finally {
    saving = false;
  }
}
  function getInitials(name: string) {
    if (!name?.trim()) return '?';

    return name
      .trim()
      .split(/\s+/)
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
      .toUpperCase();
  }

  function handleFileUpload(event: Event) {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];

    if (!file) return;

    if (!file.type.startsWith('image/')) {
      error = 'Please upload an image file.';
      return;
    }

    error = '';
    success = '';

    const reader = new FileReader();

    reader.onload = (e) => {
      const result = e.target?.result;
      if (typeof result === 'string') {
        profile_image_url = result;
      }
    };

    reader.onerror = () => {
      error = 'Could not read the selected image.';
    };

    reader.readAsDataURL(file);
  }

  function triggerFileInput() {
    fileInput?.click();
  }

  const previewName = $derived(full_name || profile?.full_name || 'Employee');
  const previewTitle = $derived(job_title || profile?.job_title || 'Unique Beauty Team');
  const previewEmail = $derived(profile?.email || '');
</script>

<style>
  @keyframes gradient-shift {
    0% {
      background: linear-gradient(135deg, #ffb3d9, #ffd4a3);
    }
    25% {
      background: linear-gradient(135deg, #ffc9e3, #ffe5b4);
    }
    50% {
      background: linear-gradient(135deg, #ffb3d9, #f0d9b5);
    }
    75% {
      background: linear-gradient(135deg, #ffc9e3, #ffd4a3);
    }
    100% {
      background: linear-gradient(135deg, #ffb3d9, #ffd4a3);
    }
  }

  :global(.gradient-avatar) {
    animation: gradient-shift 5s ease-in-out infinite;
  }
</style>

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
            <p class="text-lg font-bold text-[#6b4f4f]">Profile</p>
            <p class="text-sm text-[#9c7b7b]">Manage your personal information</p>
          </div>
        </div>
      </div>
    </div>

    <main class="p-4 md:p-6">
      {#if loading}
        <div class="rounded-3xl bg-white p-6 shadow-md">
          <p class="text-[#9c7b7b]">Loading profile...</p>
        </div>
      {:else}
        <div class="grid gap-6 lg:grid-cols-[340px_1fr]">
          <div class="rounded-3xl bg-white p-6 shadow-md">
            <div class="flex flex-col items-center text-center">
              <button
                type="button"
                onclick={triggerFileInput}
                class="mb-4 flex h-36 w-36 items-center justify-center overflow-hidden rounded-full shadow-lg transition hover:scale-[1.02]"
                title="Click to upload profile image"
              >
                {#if profile_image_url}
                  <img
                    src={profile_image_url}
                    alt="Profile preview"
                    class="h-full w-full object-cover"
                  />
                {:else}
                  <div
                    class="gradient-avatar flex h-full w-full items-center justify-center text-4xl font-bold text-white"
                  >
                    {getInitials(previewName)}
                  </div>
                {/if}
              </button>

              <button
                type="button"
                onclick={triggerFileInput}
                class="mb-5 rounded-full bg-[#fff1f7] px-4 py-2 text-sm font-medium text-[#ff2d96] transition hover:bg-[#ffe5f2]"
              >
                Change photo
              </button>

              <h2 class="text-2xl font-bold text-[#6b4f4f]">
                {previewName}
              </h2>

              <p class="mt-1 text-[#9c7b7b]">
                {previewTitle}
              </p>

              {#if previewEmail}
                <p class="mt-2 break-all text-sm text-[#b08c8c]">
                  {previewEmail}
                </p>
              {/if}
            </div>
          </div>

          <div class="rounded-3xl bg-white p-6 shadow-md">
            <div class="mb-5">
              <h1 class="text-2xl font-bold text-[#6b4f4f]">Edit Profile</h1>
              <p class="text-sm text-[#9c7b7b]">Keep your account information up to date</p>
            </div>

            <div class="space-y-5">
              <div>
                <label for="full_name" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
                  Full Name
                </label>
                <input
                  id="full_name"
                  bind:value={full_name}
                  type="text"
                  class="w-full rounded-xl border border-[#efd9dd] p-3 outline-none transition focus:border-[#ff2d96]"
                  placeholder="Enter your full name"
                />
              </div>

              <div>
                <label for="job_title" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
                  Job Title
                </label>
                <input
                  id="job_title"
                  bind:value={job_title}
                  type="text"
                  class="w-full rounded-xl border border-[#efd9dd] p-3 outline-none transition focus:border-[#ff2d96]"
                  placeholder="Example: Stylist or Wig Consultant"
                />
              </div>

              <div>
                <label for="phone" class="mb-2 block text-sm font-medium text-[#6b4f4f]">
                  Phone
                </label>
                <input
                  id="phone"
                  bind:value={phone}
                  type="text"
                  class="w-full rounded-xl border border-[#efd9dd] p-3 outline-none transition focus:border-[#ff2d96]"
                  placeholder="Enter your phone number"
                />
              </div>

              <div>
                <label
                  for="profile_image_url"
                  class="mb-2 block text-sm font-medium text-[#6b4f4f]"
                >
                  Profile Image URL
                </label>
                <input
                  id="profile_image_url"
                  bind:value={profile_image_url}
                  type="text"
                  class="w-full rounded-xl border border-[#efd9dd] p-3 outline-none transition focus:border-[#ff2d96]"
                  placeholder="Paste an image URL"
                />
                <p class="mt-2 text-xs text-[#b08c8c]">
                  You can either upload an image above or paste an image URL here.
                </p>
              </div>

              {#if error}
                <div class="rounded-2xl bg-red-50 px-4 py-3 text-sm text-red-600">
                  {error}
                </div>
              {/if}

              {#if success}
                <div class="rounded-2xl bg-green-50 px-4 py-3 text-sm text-green-700">
                  {success}
                </div>
              {/if}

              <button
                type="button"
                onclick={saveProfile}
                disabled={saving}
                class="w-full rounded-xl bg-[#6b4f4f] py-3 text-white transition hover:opacity-90 disabled:opacity-50"
              >
                {#if saving}
                  Saving...
                {:else}
                  Save Profile
                {/if}
              </button>
            </div>
          </div>
        </div>
      {/if}
    </main>
  </div>
</div>

<input
  bind:this={fileInput}
  type="file"
  accept="image/*"
  onchange={handleFileUpload}
  class="hidden"
  aria-hidden="true"
/>