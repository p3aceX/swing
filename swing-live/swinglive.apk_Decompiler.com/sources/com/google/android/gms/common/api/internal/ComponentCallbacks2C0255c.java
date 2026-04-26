package com.google.android.gms.common.api.internal;

import android.app.Activity;
import android.app.Application;
import android.content.ComponentCallbacks2;
import android.content.res.Configuration;
import android.os.Bundle;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ComponentCallbacks2C0255c implements Application.ActivityLifecycleCallbacks, ComponentCallbacks2 {
    public static final ComponentCallbacks2C0255c e = new ComponentCallbacks2C0255c();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicBoolean f3457a = new AtomicBoolean();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AtomicBoolean f3458b = new AtomicBoolean();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f3459c = new ArrayList();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f3460d = false;

    public static void b(Application application) {
        ComponentCallbacks2C0255c componentCallbacks2C0255c = e;
        synchronized (componentCallbacks2C0255c) {
            try {
                if (!componentCallbacks2C0255c.f3460d) {
                    application.registerActivityLifecycleCallbacks(componentCallbacks2C0255c);
                    application.registerComponentCallbacks(componentCallbacks2C0255c);
                    componentCallbacks2C0255c.f3460d = true;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void a(InterfaceC0254b interfaceC0254b) {
        synchronized (e) {
            this.f3459c.add(interfaceC0254b);
        }
    }

    public final void c(boolean z4) {
        synchronized (e) {
            try {
                Iterator it = this.f3459c.iterator();
                while (it.hasNext()) {
                    ((InterfaceC0254b) it.next()).a(z4);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityCreated(Activity activity, Bundle bundle) {
        boolean zCompareAndSet = this.f3457a.compareAndSet(true, false);
        this.f3458b.set(true);
        if (zCompareAndSet) {
            c(false);
        }
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityDestroyed(Activity activity) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityPaused(Activity activity) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityResumed(Activity activity) {
        boolean zCompareAndSet = this.f3457a.compareAndSet(true, false);
        this.f3458b.set(true);
        if (zCompareAndSet) {
            c(false);
        }
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityStarted(Activity activity) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public final void onActivityStopped(Activity activity) {
    }

    @Override // android.content.ComponentCallbacks
    public final void onConfigurationChanged(Configuration configuration) {
    }

    @Override // android.content.ComponentCallbacks
    public final void onLowMemory() {
    }

    @Override // android.content.ComponentCallbacks2
    public final void onTrimMemory(int i4) {
        if (i4 == 20 && this.f3457a.compareAndSet(false, true)) {
            this.f3458b.set(true);
            c(true);
        }
    }
}
