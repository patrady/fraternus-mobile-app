-- ADR 0003: parent-initiated deletion of a child's data. Deleting the
-- Member row is the single entry point — every table referencing Member Id
-- uses `on delete cascade` (see the members_and_associations, field_guide,
-- and events migrations), so this RPC's only job is authorization: confirm
-- the caller is a Guardian for this specific Member before deleting.
--
-- No `delete` RLS policy exists on public.members at all (see the
-- members_and_associations migration), so this function's own check is the
-- only door — the defense-in-depth ADR 0003 Decision 2 calls for.
create or replace function public.delete_member_data(target_member_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.user_member_associations
    where member_id = target_member_id
      and user_id = auth.uid()
      and relationship = 'guardian'
  ) then
    raise exception 'not authorized to delete this member' using errcode = '42501';
  end if;

  delete from public.members where id = target_member_id;
end;
$$;

revoke all on function public.delete_member_data(uuid) from public;
grant execute on function public.delete_member_data(uuid) to authenticated;
