// Shared onboarding components extracted from app/AuthFlow.jsx.
// These are prototype-only components layered on top of the Fraternus Design System's
// base Button/Input/Select/Checkbox — they don't exist in the DS bundle yet.
// Ported here as flat reference source for rebuilding as real widgets (e.g. in a Flutter Widget Book).

const { Button, Input, Select, Checkbox } = window.FraternusDesignSystem_9ea220 || {};

// ── PrimaryButton (full-width) ──────────────────────────────────
// The DS Button component has no width/centering override, so onboarding replicates its
// primary look directly at full width. Two sizes; optional trailing arrow; disabled state.
function PrimaryButton({ children, disabled, onClick, iconRight, size = 'lg' }) {
  const isLg = size === 'lg';
  return (
    <button type="button" disabled={disabled} onClick={disabled ? undefined : onClick} style={{
      fontFamily: 'var(--font-display)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: 'var(--tracking-button)',
      fontSize: isLg ? 16 : 15, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      width: '100%', boxSizing: 'border-box', cursor: disabled ? 'not-allowed' : 'pointer', opacity: disabled ? 0.5 : 1,
      border: 'none', color: '#fff', background: 'var(--accent-primary)', borderRadius: 'var(--radius-sm)',
      padding: isLg ? '18px 32px' : '15px 26px', minHeight: 'var(--tap-target-min)',
    }}>{children}{iconRight ? ' \u2192' : ''}</button>
  );
}

// ── SecondaryButton (outline, full-width) ───────────────────────
// Used for "Cancel", "Add Child", "I don't have any kids" — all in a 1px bordered white pill.
function SecondaryButton({ children, onClick, icon, disabled }) {
  return (
    <button type="button" onClick={onClick} disabled={disabled} style={{
      width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      font: '600 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.03em',
      color: 'var(--color-forest-green)', background: '#fff', border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-sm)', padding: '14px', cursor: disabled ? 'not-allowed' : 'pointer',
      minHeight: 'var(--tap-target-min)', opacity: disabled ? 0.5 : 1,
    }}>{icon && <Icon name={icon} size={16} tone="default" />}{children}</button>
  );
}

// ── LinkButton (underlined text, no background) ─────────────────
// Used for "Forgot Password?", "Resend Code", "Don't have an account?".
function LinkButton({ children, onClick, tone = 'muted', align = 'center' }) {
  const color = tone === 'muted' ? 'var(--text-on-light-muted)' : tone === 'brand' ? 'var(--color-forest-green)' : '#fff';
  return (
    <button type="button" onClick={onClick} style={{
      background: 'none', border: 'none', cursor: 'pointer', padding: '10px 0', textAlign: align,
      font: '600 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.03em',
      color, textDecoration: 'underline', textUnderlineOffset: 3,
    }}>{children}</button>
  );
}

// ── FieldLabel ───────────────────────────────────────────────────
function FieldLabel({ children }) {
  return (
    <div style={{ font: '700 12px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--text-on-light-muted)', marginBottom: 6 }}>
      {children}
    </div>
  );
}

// ── ScreenHeader (back chevron + uppercase title) ────────────────
function ScreenHeader({ title, onBack }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '18px 16px 6px', flexShrink: 0 }}>
      <button onClick={onBack} aria-label="Back" style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', minHeight: 'var(--tap-target-min)', minWidth: 32 }}>
        <Icon name="chevron-left" size={22} />
      </button>
      <span style={{ font: '700 20px var(--font-display)', textTransform: 'uppercase', color: 'var(--color-forest-green)' }}>{title}</span>
    </div>
  );
}

// ── ScreenShell (safe-area body + pinned footer) ─────────────────
function ScreenShell({ children, dark, footer }) {
  const SAFE_TOP = 56;
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', paddingTop: SAFE_TOP, background: dark ? 'var(--surface-dark)' : 'var(--surface-card-dim)' }}>
      <div style={{ flex: 1, overflow: 'auto' }}>{children}</div>
      {footer && <div style={{ flexShrink: 0, padding: '14px 16px calc(14px + var(--space-2))', background: dark ? 'transparent' : 'var(--surface-card-dim)' }}>{footer}</div>}
    </div>
  );
}

// ── StepProgress (segmented bar, N of total) ─────────────────────
function StepProgress({ step, total }) {
  return (
    <div style={{ display: 'flex', gap: 6, padding: '0 16px 4px' }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{ flex: 1, height: 4, borderRadius: 2, background: i < step ? 'var(--accent-primary)' : 'var(--border-subtle)' }} />
      ))}
    </div>
  );
}

// ── IconBadgeCircle (56px circle, dark or light fill, centered icon) ──
// Used for success/confirmation states: "Check Your Email", "We Love The Enthusiasm", "You're All Set".
function IconBadgeCircle({ icon, size = 56, iconSize = 28, dark = true, tone }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: dark ? 'var(--surface-dark)' : 'var(--surface-card-dim)',
    }}>
      <Icon name={icon} size={iconSize} tone={tone || (dark ? 'white' : 'default')} />
    </div>
  );
}

// ── SelectableCard (role picker: icon chip + title + description, selected state) ──
function SelectableCard({ icon, title, description, selected, onClick, muted }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'flex-start', gap: 14, textAlign: 'left', width: '100%', cursor: 'pointer',
      background: muted ? 'transparent' : '#fff', border: muted ? 'none' : `2px solid ${selected ? 'var(--accent-primary)' : 'var(--border-subtle)'}`,
      borderRadius: 'var(--radius-lg)', padding: '18px 16px', marginBottom: 14, boxSizing: 'border-box',
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: '50%', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: selected ? 'var(--accent-primary)' : 'var(--surface-card-dim)',
      }}>
        <Icon name={icon} size={22} tone={selected ? 'white' : 'default'} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ font: '700 16px var(--font-display)', textTransform: 'uppercase', color: 'var(--color-forest-green)', marginBottom: 4 }}>{title}</div>
        <div style={{ font: 'var(--text-small)', color: 'var(--text-on-light-muted)' }}>{description}</div>
      </div>
    </button>
  );
}

// ── InfoCard (bordered white card; name + subtext row used for people/summary rows) ──
function InfoCard({ initials, title, subtitle, badge, onRemove }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: '#fff', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)', padding: '14px 16px', marginBottom: 12 }}>
      {initials && (
        <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'var(--color-forest-green)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, font: '700 15px var(--font-display)' }}>{initials}</div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: '600 16px var(--font-body)', color: 'var(--color-ink)' }}>{title}</div>
        <div style={{ font: 'var(--text-small)', color: 'var(--text-on-light-muted)' }}>{subtitle}</div>
        {badge && (
          <span style={{ display: 'inline-block', marginTop: 8, font: '700 11px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.04em', color: '#fff', background: 'var(--accent-primary)', borderRadius: 'var(--radius-sm)', padding: '4px 10px' }}>{badge}</span>
        )}
      </div>
      {onRemove && (
        <button onClick={onRemove} aria-label="Remove" style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, minHeight: 'var(--tap-target-min)' }}>
          <Icon name="x" size={18} tone="default" />
        </button>
      )}
    </div>
  );
}

// ── FormCard (bordered white panel wrapping a set of fields + save/cancel row) ──
function FormCard({ children, onSave, onCancel, canSave, saveLabel = 'Save' }) {
  return (
    <div style={{ background: '#fff', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)', padding: 16, marginBottom: 16 }}>
      {children}
      <div style={{ display: 'flex', gap: 10, marginTop: 4 }}>
        <SecondaryButton onClick={onCancel}>Cancel</SecondaryButton>
        <button onClick={onSave} disabled={!canSave} style={{
          flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
          font: '600 15px var(--font-display)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-button)',
          color: '#fff', background: 'var(--accent-primary)', border: 'none', opacity: canSave ? 1 : 0.5,
          borderRadius: 'var(--radius-sm)', padding: '13px', cursor: canSave ? 'pointer' : 'not-allowed', minHeight: 'var(--tap-target-min)',
        }}>{saveLabel}</button>
      </div>
    </div>
  );
}

// ── DangerButton (destructive full-width outline) ────────────────
// Used for "Remove Child", "Log Out" — same shape as SecondaryButton but error-colored text.
function DangerButton({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: '100%', font: '600 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.03em',
      color: 'var(--color-error)', background: '#fff', border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-sm)', padding: '14px', cursor: 'pointer', minHeight: 'var(--tap-target-min)',
    }}>{children}</button>
  );
}

// ── Avatar (circular initials) ────────────────────────────────────
function Avatar({ initials, size = 40 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', background: 'var(--color-forest-green)', color: '#fff',
      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      font: `700 ${Math.round(size * 0.36)}px var(--font-display)`,
    }}>{initials}</div>
  );
}

// ── BottomTabBar (primary app navigation, icon + label, 4 items) ──
function BottomTabBar({ tabs, activeKey, onChange }) {
  return (
    <div style={{ display: 'flex', background: 'var(--surface-dark)', borderTop: '1px solid rgba(255,255,255,0.08)', paddingTop: 10, paddingBottom: 30 }}>
      {tabs.map(t => {
        const active = t.key === activeKey;
        return (
          <button key={t.key} onClick={() => onChange(t.key)} style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5,
            background: 'none', border: 'none', cursor: 'pointer', padding: '4px 2px', minHeight: 'var(--tap-target-min)',
          }}>
            <Icon name={t.icon} tone={active ? 'terracotta' : 'white'} opacity={active ? 1 : 0.62} size={24} />
            <span style={{ font: '600 11px var(--font-display)', letterSpacing: '0.04em', textTransform: 'uppercase', color: active ? 'var(--accent-primary)' : 'rgba(205,218,213,0.62)' }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ── PersonTabs (segmented text-tab switcher, per-person status) ───
// Distinct from BottomTabBar: underline indicator instead of icon+color, plus an inline
// done/in-progress status icon per tab. Used on Today/Guide/Challenges to switch household member.
function PersonTabs({ people, activeKey, onChange }) {
  return (
    <div style={{ display: 'flex', gap: 22, borderBottom: '1px solid var(--border-subtle)' }}>
      {people.map(p => {
        const active = p.key === activeKey;
        return (
          <button key={p.key} onClick={() => onChange(p.key)} style={{
            display: 'flex', alignItems: 'center', gap: 5, font: 'var(--text-button)', fontSize: 14,
            textTransform: 'uppercase', letterSpacing: 'var(--tracking-button)',
            color: active ? 'var(--color-forest-green)' : 'var(--text-on-light-muted)', background: 'none', border: 'none',
            borderBottom: active ? '3px solid var(--accent-primary)' : '3px solid transparent',
            padding: '12px 2px', cursor: 'pointer', minHeight: 'var(--tap-target-min)',
          }}>
            {p.label}
            {p.status === 'done' && <Icon name="circle-check" size={14} tone="success" />}
            {p.status === 'in_progress' && <Icon name="circle-dashed" size={14} tone="terracotta" />}
          </button>
        );
      })}
    </div>
  );
}

// ── ListRow (generic: leading icon/avatar + label/sublabel + chevron) ──
// Covers ProfileRow, TodoRow, "Others Attending" row — same shape, different leading slot / trailing control.
function ListRow({ leading, label, sublabel, trailing, chevron = true, bordered = true, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, width: '100%', textAlign: 'left', cursor: onClick ? 'pointer' : 'default',
      background: bordered ? '#fff' : 'none', border: bordered ? '1px solid var(--border-subtle)' : 'none',
      borderRadius: bordered ? 'var(--radius-lg)' : 0, padding: bordered ? '14px 16px' : '11px 0',
      marginBottom: bordered ? 12 : 0, minHeight: 'var(--tap-target-min)', boxSizing: 'border-box',
    }}>
      {leading}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: '600 16px var(--font-body)', color: 'var(--color-ink)' }}>{label}</div>
        {sublabel && <div style={{ font: 'var(--text-small)', color: 'var(--text-on-light-muted)', marginTop: 2 }}>{sublabel}</div>}
      </div>
      {trailing}
      {chevron && !trailing && <Icon name="chevron-right" size={18} tone="default" />}
    </button>
  );
}

// ── RsvpToggle (two-option pill group: Going / Can't, tri-state color) ──
function RsvpToggle({ status, onChange }) {
  const opt = (val, label) => (
    <button onClick={() => onChange(val)} style={{
      font: '600 12px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.03em',
      padding: '8px 14px', borderRadius: 'var(--radius-sm)', cursor: 'pointer', minHeight: 36,
      border: status === val ? 'none' : '1px solid var(--border-subtle)',
      background: status === val ? (val === 'yes' ? 'var(--color-success)' : val === 'no' ? 'var(--color-error)' : 'var(--color-tan-dim)') : '#fff',
      color: status === val ? '#fff' : 'var(--text-on-light-muted)',
    }}>{label}</button>
  );
  return <div style={{ display: 'flex', gap: 8 }}>{opt('yes', 'Going')}{opt('no', "Can't")}</div>;
}

// ── Pill / badge tags (status + category labels) ───────────────────
// Filled pill: role/scope badges ("Captain", "Entire Chapter"). Small square-radius tag: "New"/soon-time.
function Pill({ children, tone = 'dark', icon }) {
  const bg = tone === 'dark' ? 'var(--color-forest-green)' : tone === 'primary' ? 'var(--accent-primary)' : 'var(--color-tan-dim)';
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, font: '700 11px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.04em', color: '#fff', background: bg, borderRadius: 'var(--radius-pill)', padding: '5px 12px', whiteSpace: 'nowrap' }}>
      {icon && <Icon name={icon} size={11} tone="white" />}{children}
    </span>
  );
}

// ── StreakBanner (dark rounded bar, flame icon + count) ─────────────
function StreakBanner({ count, label = 'Day Streak' }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, font: '700 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.04em', color: '#fff', background: 'var(--surface-dark)', borderRadius: 'var(--radius-md)', padding: 14 }}>
      <Icon name="flame" size={16} tone="terracotta" />{count} {label}
    </div>
  );
}

// ── RepDots (row of small circular rep-completion indicators) ───────
function RepDots({ reps, doneCount, editable, onToggle }) {
  return (
    <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
      {Array.from({ length: reps }).map((_, i) => {
        const done = i < doneCount;
        if (!editable) return <div key={i} style={{ width: 9, height: 9, borderRadius: '50%', background: done ? 'var(--color-forest-green)' : 'var(--border-subtle)' }} />;
        return <button key={i} onClick={() => onToggle(i)} style={{ width: 20, height: 20, borderRadius: '50%', padding: 0, cursor: 'pointer', border: done ? 'none' : '1px solid var(--border-subtle)', background: done ? 'var(--color-forest-green)' : '#fff' }} />;
      })}
    </div>
  );
}

// ── ContentCard (bordered white card; generic label + body, e.g. quote/section/event) ──
function ContentCard({ eyebrow, title, subtitle, children, onLike, liked }) {
  return (
    <div style={{ background: '#fff', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)', padding: '18px 18px 20px', marginBottom: 16 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 10, marginBottom: subtitle ? 6 : 10 }}>
        <div>
          {eyebrow && <div style={{ font: '700 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-eyebrow)', color: 'var(--accent-primary)' }}>{eyebrow}</div>}
          {title && <div style={{ font: '600 18px var(--font-display)', color: 'var(--color-forest-green)' }}>{title}</div>}
        </div>
        {onLike && (
          <button onClick={onLike} aria-label="Like" style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', lineHeight: 0, flexShrink: 0 }}>
            <Icon name="heart" size={19} tone={liked ? 'error' : 'default'} />
          </button>
        )}
      </div>
      {subtitle && <div style={{ font: 'italic 400 13px var(--font-body)', color: 'var(--text-on-light-muted)', marginBottom: 12 }}>{subtitle}</div>}
      {children}
    </div>
  );
}

// ── DarkFeatureCard (dark surface card with icon + CTA — temperament result, congrats state) ──
function DarkFeatureCard({ icon, eyebrow, value, body, ctaLabel, onCta }) {
  return (
    <div style={{ background: 'var(--surface-dark)', borderRadius: 'var(--radius-lg)', padding: '26px 20px 22px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
      {icon && <div style={{ marginBottom: 14 }}><Icon name={icon} size={32} tone="white" /></div>}
      {eyebrow && <div style={{ font: '700 13px var(--font-display)', textTransform: 'uppercase', letterSpacing: 'var(--tracking-eyebrow)', color: 'var(--accent-primary)', marginBottom: 6 }}>{eyebrow}</div>}
      {value && <div style={{ font: '700 22px var(--font-display)', textTransform: 'uppercase', color: '#fff', marginBottom: 18 }}>{value}</div>}
      {body && <div style={{ font: 'var(--text-body)', color: 'var(--text-on-dark-muted)', marginBottom: 16 }}>{body}</div>}
      {ctaLabel && (
        <button onClick={onCta} style={{ font: '600 12px var(--font-display)', textTransform: 'uppercase', letterSpacing: '0.03em', color: '#fff', background: 'transparent', border: '1px solid rgba(255,255,255,0.4)', borderRadius: 'var(--radius-sm)', padding: '11px 22px', cursor: 'pointer', minHeight: 'var(--tap-target-min)' }}>{ctaLabel}</button>
      )}
    </div>
  );
}

// ── ContinuousProgressBar (single filled track — temperament quiz) ──
// Distinct from StepProgress: one continuous bar with animated width, not discrete segments.
function ContinuousProgressBar({ index, total }) {
  return (
    <div style={{ height: 6, background: 'var(--border-subtle)', borderRadius: 'var(--radius-pill)', overflow: 'hidden' }}>
      <div style={{ height: '100%', width: `${((index + 1) / total) * 100}%`, background: 'var(--accent-primary)', borderRadius: 'var(--radius-pill)', transition: 'width 350ms ease' }} />
    </div>
  );
}

// ── JournalTextarea (freeform multi-line text entry — not yet a DS component) ──
function JournalTextarea({ value, onChange, placeholder, rows = 4 }) {
  return (
    <textarea value={value} onChange={onChange} placeholder={placeholder} rows={rows} style={{
      font: 'var(--text-body)', fontSize: 15, padding: '14px 16px', boxSizing: 'border-box',
      borderRadius: 'var(--radius-sm)', border: '1px solid var(--border-subtle)', background: '#fff',
      color: 'var(--color-ink)', width: '100%', outline: 'none', resize: 'none', fontFamily: 'var(--font-body)',
    }} />
  );
}

Object.assign(window, {
  PrimaryButton, SecondaryButton, LinkButton, DangerButton, FieldLabel, ScreenHeader, ScreenShell,
  StepProgress, ContinuousProgressBar, IconBadgeCircle, SelectableCard, InfoCard, FormCard, Avatar,
  BottomTabBar, PersonTabs, ListRow, RsvpToggle, Pill, StreakBanner, RepDots, ContentCard,
  DarkFeatureCard, JournalTextarea,
});
