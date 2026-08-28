<script lang="ts">
  let {
    name,
    role = 'EMPLOYEE',
    email = '',
    image = ''
  }: {
    name: string;
    role?: string;
    email?: string;
    image?: string;
  } = $props();

  function getInitials(name: string) {
    if (!name) return '?';
    return name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
      .toUpperCase();
  }
</script>

<div class="rounded-2xl bg-white p-5 shadow-md">
  <div class="flex items-center gap-4">
    {#if image}
      <img src={image} alt={name} class="h-14 w-14 rounded-full object-cover" />
    {:else}
      <div
        class="flex h-14 w-14 items-center justify-center rounded-full bg-[#f7edee] text-lg font-bold text-[#6b4f4f]"
      >
        {getInitials(name)}
      </div>
    {/if}

    <div class="min-w-0">
      <h3 class="truncate font-semibold text-[#6b4f4f]">{name}</h3>
      <p class="text-sm text-[#9c7b7b]">{role}</p>
      {#if email}
        <p class="truncate text-sm text-[#b08c8c]">{email}</p>
      {/if}
    </div>
  </div>
</div>