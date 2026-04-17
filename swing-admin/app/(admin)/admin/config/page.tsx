"use client";

import { useState, useEffect } from "react";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useConfigsQuery, useUpdateConfigMutation } from "@/lib/queries";
import type { ConfigRecord } from "@/lib/api";

function isBoolean(value: string) {
  return value === "true" || value === "false";
}

function isNumeric(value: string) {
  return !isNaN(Number(value)) && value.trim() !== "";
}

function ConfigItem({
  config,
  onSave,
  isSaving,
}: {
  config: ConfigRecord;
  onSave: (key: string, value: string) => void;
  isSaving: boolean;
}) {
  const [localValue, setLocalValue] = useState(config.value);

  useEffect(() => {
    setLocalValue(config.value);
  }, [config.value]);

  const isDirty = localValue !== config.value;

  if (isBoolean(config.value)) {
    return (
      <div className="flex items-center justify-between rounded-lg border p-4">
        <div>
          <div className="font-medium">{config.key}</div>
          {config.description && <div className="text-sm text-muted-foreground">{config.description}</div>}
        </div>
        <div className="flex items-center gap-3">
          <Switch
            checked={localValue === "true"}
            onCheckedChange={(checked) => {
              const newVal = checked ? "true" : "false";
              setLocalValue(newVal);
              onSave(config.key, newVal);
            }}
          />
        </div>
      </div>
    );
  }

  if (isNumeric(config.value)) {
    return (
      <div className="space-y-2">
        <div className="font-medium text-sm">{config.key}</div>
        {config.description && <div className="text-xs text-muted-foreground">{config.description}</div>}
        <div className="flex gap-2">
          <Input
            type="number"
            value={localValue}
            onChange={(e) => setLocalValue(e.target.value)}
            className="max-w-[200px]"
          />
          {isDirty && (
            <Button size="sm" disabled={isSaving} onClick={() => onSave(config.key, localValue)}>
              Save
            </Button>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <div className="font-medium text-sm">{config.key}</div>
      {config.description && <div className="text-xs text-muted-foreground">{config.description}</div>}
      <div className="flex gap-2">
        <Input value={localValue} onChange={(e) => setLocalValue(e.target.value)} />
        {isDirty && (
          <Button size="sm" disabled={isSaving} onClick={() => onSave(config.key, localValue)}>
            Save
          </Button>
        )}
      </div>
    </div>
  );
}

export default function ConfigPage() {
  const query = useConfigsQuery();
  const updateMutation = useUpdateConfigMutation();

  const configs = query.data ?? [];
  const flagConfigs = configs.filter((c) => isBoolean(c.value));
  const numericConfigs = configs.filter((c) => isNumeric(c.value) && !isBoolean(c.value));
  const otherConfigs = configs.filter((c) => !isBoolean(c.value) && !isNumeric(c.value));

  return (
    <div className="space-y-6">
      <PageHeader title="Config" description="Manage platform configuration settings stored in the database." />

      {query.isLoading && (
        <div className="rounded-xl border bg-card p-8 text-center text-sm text-muted-foreground">
          Loading configuration...
        </div>
      )}

      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load config: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}

      {!query.isLoading && configs.length > 0 && (
        <div className="grid gap-6 xl:grid-cols-2">
          {flagConfigs.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Feature Flags</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {flagConfigs.map((config) => (
                  <ConfigItem
                    key={config.key}
                    config={config}
                    onSave={(key, value) => updateMutation.mutate({ key, value })}
                    isSaving={updateMutation.isPending}
                  />
                ))}
              </CardContent>
            </Card>
          )}

          {numericConfigs.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Numeric Values</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {numericConfigs.map((config) => (
                  <ConfigItem
                    key={config.key}
                    config={config}
                    onSave={(key, value) => updateMutation.mutate({ key, value })}
                    isSaving={updateMutation.isPending}
                  />
                ))}
              </CardContent>
            </Card>
          )}

          {otherConfigs.length > 0 && (
            <Card className="xl:col-span-2">
              <CardHeader>
                <CardTitle>Other Settings</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {otherConfigs.map((config) => (
                  <ConfigItem
                    key={config.key}
                    config={config}
                    onSave={(key, value) => updateMutation.mutate({ key, value })}
                    isSaving={updateMutation.isPending}
                  />
                ))}
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {!query.isLoading && configs.length === 0 && !query.isError && (
        <div className="rounded-xl border bg-card p-8 text-center text-sm text-muted-foreground">
          No configuration keys found. Add entries to the PlatformConfig table to manage them here.
        </div>
      )}
    </div>
  );
}
