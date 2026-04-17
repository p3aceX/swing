"use client";

import Link from "next/link";
import { useParams, useSearchParams } from "next/navigation";
import { ArrowLeft, MapPin, Phone, Star } from "lucide-react";
import { ArenaForm } from "@/components/admin/arena-form";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useArenaQuery, useUpdateArenaMutation } from "@/lib/queries";
import type { CreateArenaBody } from "@/lib/api";
import { formatCurrencyInr, formatDate, paiseToInr } from "@/lib/utils";

export default function ArenaDetailPage() {
  const params = useParams<{ id: string }>();
  const searchParams = useSearchParams();
  const arenaId = params?.id ?? null;
  const mode = searchParams.get("mode") === "edit" ? "edit" : "view";
  const arenaQuery = useArenaQuery(arenaId);
  const updateArenaMutation = useUpdateArenaMutation();

  function handleUpdate(payload: CreateArenaBody) {
    if (!arenaId) return;
    updateArenaMutation.mutate({ id: arenaId, data: payload });
  }

  if (arenaQuery.isLoading) {
    return (
      <div className="space-y-6">
        <PageHeader
          title="Arena"
          description="Loading arena details..."
          action={
            <Button asChild variant="outline">
              <Link href="/admin/arenas">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back to Arenas
              </Link>
            </Button>
          }
        />
        <div className="rounded-xl border bg-card p-8 text-sm text-muted-foreground">
          Loading arena record...
        </div>
      </div>
    );
  }

  if (arenaQuery.isError || !arenaQuery.data) {
    return (
      <div className="space-y-6">
        <PageHeader
          title="Arena"
          description="The requested arena could not be loaded."
          action={
            <Button asChild variant="outline">
              <Link href="/admin/arenas">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back to Arenas
              </Link>
            </Button>
          }
        />
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load arena: {(arenaQuery.error as Error)?.message ?? "Unknown error"}
        </div>
      </div>
    );
  }

  const arena = arenaQuery.data;
  const ownerName =
    arena.owner?.user?.name ??
    arena.owner?.businessName ??
    "Unknown owner";
  const ownerPhone = arena.owner?.user?.phone ?? "N/A";
  const defaultTab = mode === "edit" ? "edit" : "overview";
  const amenities = [
    arena.hasParking ? "Parking" : null,
    arena.hasLights ? "Lights" : null,
    arena.hasWashrooms ? "Washrooms" : null,
    arena.hasCanteen ? "Canteen" : null,
    arena.hasCCTV ? "CCTV" : null,
    arena.hasScorer ? "Scorer" : null,
  ].filter((feature): feature is string => Boolean(feature));

  return (
    <div className="space-y-6">
      <PageHeader
        title={arena.name}
        description={`${arena.city}, ${arena.state}`}
        action={
          <Button asChild variant="outline">
            <Link href="/admin/arenas">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back
            </Link>
          </Button>
        }
      />

      <div className="flex flex-wrap gap-2">
        <Badge variant={arena.isVerified ? "success" : "warning"}>
          {arena.isVerified ? "Verified" : "Unverified"}
        </Badge>
        <Badge variant={arena.isSwingArena ? "success" : "outline"}>
          {arena.isSwingArena ? "Swing Arena" : "Regular Arena"}
        </Badge>
        <Badge variant={arena.isActive ? "success" : "outline"}>
          {arena.isActive ? "Active" : "Inactive"}
        </Badge>
        <Badge variant="outline">{arena.planTier}</Badge>
        {arena.arenaGrade ? <Badge variant="outline">{arena.arenaGrade}</Badge> : null}
      </div>

      <Tabs defaultValue={defaultTab}>
        <TabsList className="h-auto w-full flex-wrap justify-start gap-2 rounded-xl border bg-card p-2">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="edit">Edit Arena</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">Owner</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm">
                <div className="font-medium">{ownerName}</div>
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Phone className="h-4 w-4" />
                  {ownerPhone}
                </div>
                <div className="text-xs text-muted-foreground">Owner ID: {arena.ownerId}</div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">Location</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm">
                <div className="flex items-start gap-2">
                  <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-muted-foreground" />
                  <div>
                    <div>{arena.address}</div>
                    <div className="text-muted-foreground">
                      {arena.city}, {arena.state} {arena.pincode}
                    </div>
                  </div>
                </div>
                <div className="text-xs text-muted-foreground">
                  {arena.latitude}, {arena.longitude}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">Booking</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm">
                <div>
                  Open: <span className="font-medium">{arena.openTime}</span> to{" "}
                  <span className="font-medium">{arena.closeTime}</span>
                </div>
                <div>
                  Advance booking: <span className="font-medium">{arena.advanceBookingDays} days</span>
                </div>
                <div>
                  Buffer: <span className="font-medium">{arena.bufferMins} mins</span>
                </div>
                <div>
                  Cancellation: <span className="font-medium">{arena.cancellationHours} hours</span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">Stats</CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 text-sm">
                <div className="flex items-center gap-2">
                  <Star className="h-4 w-4 text-muted-foreground" />
                  <span className="font-medium">{arena.rating.toFixed(1)}</span>
                  <span className="text-muted-foreground">from {arena.totalRatings} ratings</span>
                </div>
                <div>Created: {formatDate(arena.createdAt, "dd MMM yyyy")}</div>
                <div>Updated: {formatDate(arena.updatedAt, "dd MMM yyyy, hh:mm a")}</div>
              </CardContent>
            </Card>
          </div>

          <div className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
            <Card>
              <CardHeader>
                <CardTitle>Photos</CardTitle>
                <CardDescription>Arena listing photos used across the product.</CardDescription>
              </CardHeader>
              <CardContent>
                {arena.photoUrls && arena.photoUrls.length > 0 ? (
                  <div className="grid grid-cols-2 gap-3 md:grid-cols-3">
                    {arena.photoUrls.map((url, index) => (
                      <div key={`${url}-${index}`} className="overflow-hidden rounded-xl border bg-muted/20">
                        <img
                          src={url}
                          alt={`${arena.name} photo ${index + 1}`}
                          className="aspect-[4/3] w-full object-cover"
                        />
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="rounded-xl border border-dashed p-6 text-sm text-muted-foreground">
                    No photos uploaded yet.
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Facilities</CardTitle>
                <CardDescription>Quick summary of supported sports and amenities.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Sports</div>
                  <div className="flex flex-wrap gap-2">
                    {arena.sports && arena.sports.length > 0 ? (
                      arena.sports.map((sport) => (
                        <Badge key={sport} variant="outline">{sport}</Badge>
                      ))
                    ) : (
                      <span className="text-sm text-muted-foreground">No sports configured.</span>
                    )}
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Amenities</div>
                  <div className="flex flex-wrap gap-2">
                    {amenities.map((feature) => (
                        <Badge key={feature} variant="outline">{feature}</Badge>
                      ))}
                    {amenities.length === 0 ? (
                      <span className="text-sm text-muted-foreground">No amenities configured.</span>
                    ) : null}
                  </div>
                </div>
                {arena.description ? (
                  <div className="space-y-2">
                    <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Description</div>
                    <p className="text-sm text-muted-foreground">{arena.description}</p>
                  </div>
                ) : null}
              </CardContent>
            </Card>
          </div>

          <div className="grid gap-6 xl:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Units</CardTitle>
                <CardDescription>Bookable arena units like grounds, nets, and turfs.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {arena.units && arena.units.length > 0 ? (
                  arena.units.map((unit) => (
                    <div key={unit.id} className="rounded-xl border p-4">
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <div>
                          <div className="font-medium">{unit.name}</div>
                          <div className="text-sm text-muted-foreground">
                            {unit.unitType} · {unit.sport}
                          </div>
                        </div>
                        <Badge variant={unit.isActive ? "success" : "outline"}>
                          {unit.isActive ? "Active" : "Inactive"}
                        </Badge>
                      </div>
                      <div className="mt-3 grid gap-2 text-sm text-muted-foreground md:grid-cols-2">
                        <div>Capacity: {unit.capacity}</div>
                        <div>Price: {formatCurrencyInr(paiseToInr(unit.pricePerHourPaise))}/hour</div>
                        <div>Min slot: {unit.minSlotMins} mins</div>
                        <div>Max slot: {unit.maxSlotMins} mins</div>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="rounded-xl border border-dashed p-6 text-sm text-muted-foreground">
                    No units configured.
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Addons</CardTitle>
                <CardDescription>Optional extras that can be sold with arena bookings.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {arena.addons && arena.addons.length > 0 ? (
                  arena.addons.map((addon) => (
                    <div key={addon.id} className="rounded-xl border p-4">
                      <div className="flex flex-wrap items-center justify-between gap-2">
                        <div>
                          <div className="font-medium">{addon.name}</div>
                          <div className="text-sm text-muted-foreground">
                            {formatCurrencyInr(paiseToInr(addon.pricePaise))} · {addon.unit}
                          </div>
                        </div>
                        <Badge variant={addon.isAvailable ? "success" : "outline"}>
                          {addon.isAvailable ? "Available" : "Unavailable"}
                        </Badge>
                      </div>
                      {addon.description ? (
                        <p className="mt-3 text-sm text-muted-foreground">{addon.description}</p>
                      ) : null}
                    </div>
                  ))
                ) : (
                  <div className="rounded-xl border border-dashed p-6 text-sm text-muted-foreground">
                    No addons configured.
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="edit" className="space-y-6">
          <ArenaForm
            initialArena={arena}
            mode="edit"
            submitting={updateArenaMutation.isPending}
            submitLabel="Save Arena"
            onSubmit={handleUpdate}
          />
        </TabsContent>
      </Tabs>
    </div>
  );
}
