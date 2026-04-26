package g1;

import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.os.Bundle;
import android.os.Trace;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import com.google.android.gms.common.api.internal.ComponentCallbacks2C0255c;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import com.google.crypto.tink.shaded.protobuf.S;
import com.google.firebase.FirebaseCommonRegistrar;
import com.google.firebase.components.ComponentDiscoveryService;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.concurrent.ExecutorsRegistrar;
import com.google.firebase.provider.FirebaseInitProvider;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;
import l1.C0522a;
import m1.k;
import o3.C0592H;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public static final Object f4305i = new Object();

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public static final n.b f4306j = new n.b();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f4307a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f4308b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final j f4309c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final l1.g f4310d;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final InterfaceC0634a f4312g;
    public final AtomicBoolean e = new AtomicBoolean(false);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final AtomicBoolean f4311f = new AtomicBoolean();

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final CopyOnWriteArrayList f4313h = new CopyOnWriteArrayList();

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r1v12, types: [java.util.List] */
    /* JADX WARN: Type inference failed for: r1v6, types: [java.util.ArrayList] */
    /* JADX WARN: Type inference failed for: r1v7, types: [java.util.List] */
    public f(Context context, String str, j jVar) {
        ?? arrayList;
        final int i4 = 1;
        final int i5 = 0;
        new CopyOnWriteArrayList();
        this.f4307a = context;
        F.d(str);
        this.f4308b = str;
        this.f4309c = jVar;
        C0406a c0406a = FirebaseInitProvider.f3869a;
        Trace.beginSection("Firebase");
        Trace.beginSection("ComponentDiscovery");
        ArrayList arrayList2 = new ArrayList();
        Bundle bundle = null;
        try {
            PackageManager packageManager = context.getPackageManager();
            if (packageManager == null) {
                Log.w("ComponentDiscovery", "Context has no PackageManager.");
            } else {
                ServiceInfo serviceInfo = packageManager.getServiceInfo(new ComponentName(context, (Class<?>) ComponentDiscoveryService.class), 128);
                if (serviceInfo == null) {
                    Log.w("ComponentDiscovery", ComponentDiscoveryService.class + " has no service info.");
                } else {
                    bundle = serviceInfo.metaData;
                }
            }
        } catch (PackageManager.NameNotFoundException unused) {
            Log.w("ComponentDiscovery", "Application info not found.");
        }
        if (bundle == null) {
            Log.w("ComponentDiscovery", "Could not retrieve metadata, returning empty list of registrars.");
            arrayList = Collections.EMPTY_LIST;
        } else {
            arrayList = new ArrayList();
            for (String str2 : bundle.keySet()) {
                if ("com.google.firebase.components.ComponentRegistrar".equals(bundle.get(str2)) && str2.startsWith("com.google.firebase.components:")) {
                    arrayList.add(str2.substring(31));
                }
            }
        }
        for (final String str3 : arrayList) {
            arrayList2.add(new InterfaceC0634a() { // from class: l1.c
                @Override // q1.InterfaceC0634a
                public final Object get() {
                    switch (i5) {
                        case 0:
                            String str4 = (String) str3;
                            try {
                                Class<?> cls = Class.forName(str4);
                                if (ComponentRegistrar.class.isAssignableFrom(cls)) {
                                    return (ComponentRegistrar) cls.getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
                                }
                                throw new m("Class " + str4 + " is not an instance of com.google.firebase.components.ComponentRegistrar");
                            } catch (ClassNotFoundException unused2) {
                                Log.w("ComponentDiscovery", "Class " + str4 + " is not an found.");
                                return null;
                            } catch (IllegalAccessException e) {
                                throw new m(S.g("Could not instantiate ", str4, "."), e);
                            } catch (InstantiationException e4) {
                                throw new m(S.g("Could not instantiate ", str4, "."), e4);
                            } catch (NoSuchMethodException e5) {
                                throw new m(B1.a.m("Could not instantiate ", str4), e5);
                            } catch (InvocationTargetException e6) {
                                throw new m(B1.a.m("Could not instantiate ", str4), e6);
                            }
                        default:
                            return (ComponentRegistrar) str3;
                    }
                }
            });
        }
        Trace.endSection();
        Trace.beginSection("Runtime");
        k kVar = k.f5790a;
        ArrayList arrayList3 = new ArrayList();
        ArrayList arrayList4 = new ArrayList();
        arrayList3.addAll(arrayList2);
        final FirebaseCommonRegistrar firebaseCommonRegistrar = new FirebaseCommonRegistrar();
        arrayList3.add(new InterfaceC0634a() { // from class: l1.c
            @Override // q1.InterfaceC0634a
            public final Object get() {
                switch (i4) {
                    case 0:
                        String str4 = (String) firebaseCommonRegistrar;
                        try {
                            Class<?> cls = Class.forName(str4);
                            if (ComponentRegistrar.class.isAssignableFrom(cls)) {
                                return (ComponentRegistrar) cls.getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
                            }
                            throw new m("Class " + str4 + " is not an instance of com.google.firebase.components.ComponentRegistrar");
                        } catch (ClassNotFoundException unused2) {
                            Log.w("ComponentDiscovery", "Class " + str4 + " is not an found.");
                            return null;
                        } catch (IllegalAccessException e) {
                            throw new m(S.g("Could not instantiate ", str4, "."), e);
                        } catch (InstantiationException e4) {
                            throw new m(S.g("Could not instantiate ", str4, "."), e4);
                        } catch (NoSuchMethodException e5) {
                            throw new m(B1.a.m("Could not instantiate ", str4), e5);
                        } catch (InvocationTargetException e6) {
                            throw new m(B1.a.m("Could not instantiate ", str4), e6);
                        }
                    default:
                        return (ComponentRegistrar) firebaseCommonRegistrar;
                }
            }
        });
        final ExecutorsRegistrar executorsRegistrar = new ExecutorsRegistrar();
        arrayList3.add(new InterfaceC0634a() { // from class: l1.c
            @Override // q1.InterfaceC0634a
            public final Object get() {
                switch (i4) {
                    case 0:
                        String str4 = (String) executorsRegistrar;
                        try {
                            Class<?> cls = Class.forName(str4);
                            if (ComponentRegistrar.class.isAssignableFrom(cls)) {
                                return (ComponentRegistrar) cls.getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
                            }
                            throw new m("Class " + str4 + " is not an instance of com.google.firebase.components.ComponentRegistrar");
                        } catch (ClassNotFoundException unused2) {
                            Log.w("ComponentDiscovery", "Class " + str4 + " is not an found.");
                            return null;
                        } catch (IllegalAccessException e) {
                            throw new m(S.g("Could not instantiate ", str4, "."), e);
                        } catch (InstantiationException e4) {
                            throw new m(S.g("Could not instantiate ", str4, "."), e4);
                        } catch (NoSuchMethodException e5) {
                            throw new m(B1.a.m("Could not instantiate ", str4), e5);
                        } catch (InvocationTargetException e6) {
                            throw new m(B1.a.m("Could not instantiate ", str4), e6);
                        }
                    default:
                        return (ComponentRegistrar) executorsRegistrar;
                }
            }
        });
        arrayList4.add(C0522a.b(context, Context.class, new Class[0]));
        arrayList4.add(C0522a.b(this, f.class, new Class[0]));
        arrayList4.add(C0522a.b(jVar, j.class, new Class[0]));
        C0592H c0592h = new C0592H();
        if (w.g.a(context) && FirebaseInitProvider.f3870b.get()) {
            arrayList4.add(C0522a.b(c0406a, C0406a.class, new Class[0]));
        }
        l1.g gVar = new l1.g(arrayList3, arrayList4, c0592h);
        this.f4310d = gVar;
        Trace.endSection();
        this.f4312g = gVar.c(p1.c.class);
        c cVar = new c(this);
        a();
        if (this.e.get()) {
            ComponentCallbacks2C0255c.e.f3457a.get();
        }
        this.f4313h.add(cVar);
        Trace.endSection();
    }

    public static ArrayList b() {
        ArrayList arrayList = new ArrayList();
        synchronized (f4305i) {
            try {
                for (f fVar : (n.j) f4306j.values()) {
                    fVar.a();
                    arrayList.add(fVar.f4308b);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        Collections.sort(arrayList);
        return arrayList;
    }

    public static f c() {
        f fVar;
        synchronized (f4305i) {
            try {
                fVar = (f) f4306j.getOrDefault("[DEFAULT]", null);
                if (fVar == null) {
                    throw new IllegalStateException("Default FirebaseApp is not initialized in this process " + G0.a.c() + ". Make sure to call FirebaseApp.initializeApp(Context) first.");
                }
                ((p1.c) fVar.f4312g.get()).b();
            } catch (Throwable th) {
                throw th;
            }
        }
        return fVar;
    }

    public static f d(String str) {
        f fVar;
        String str2;
        synchronized (f4305i) {
            try {
                fVar = (f) f4306j.getOrDefault(str.trim(), null);
                if (fVar == null) {
                    ArrayList arrayListB = b();
                    if (arrayListB.isEmpty()) {
                        str2 = "";
                    } else {
                        str2 = "Available app names: " + TextUtils.join(", ", arrayListB);
                    }
                    throw new IllegalStateException("FirebaseApp with name " + str + " doesn't exist. " + str2);
                }
                ((p1.c) fVar.f4312g.get()).b();
            } finally {
            }
        }
        return fVar;
    }

    public static f g(Context context) {
        synchronized (f4305i) {
            try {
                if (f4306j.containsKey("[DEFAULT]")) {
                    return c();
                }
                j jVarA = j.a(context);
                if (jVarA == null) {
                    Log.w("FirebaseApp", "Default FirebaseApp failed to initialize because no default options were found. This usually means that com.google.gms:google-services was not applied to your gradle project.");
                    return null;
                }
                return h(context, jVarA);
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public static f h(Context context, j jVar) {
        f fVar;
        AtomicReference atomicReference = d.f4302a;
        if (context.getApplicationContext() instanceof Application) {
            Application application = (Application) context.getApplicationContext();
            AtomicReference atomicReference2 = d.f4302a;
            if (atomicReference2.get() == null) {
                d dVar = new d();
                while (true) {
                    if (atomicReference2.compareAndSet(null, dVar)) {
                        ComponentCallbacks2C0255c.b(application);
                        ComponentCallbacks2C0255c.e.a(dVar);
                        break;
                    }
                    if (atomicReference2.get() != null) {
                        break;
                    }
                }
            }
        }
        if (context.getApplicationContext() != null) {
            context = context.getApplicationContext();
        }
        synchronized (f4305i) {
            n.b bVar = f4306j;
            F.i("FirebaseApp name [DEFAULT] already exists!", !bVar.containsKey("[DEFAULT]"));
            F.h(context, "Application context cannot be null.");
            fVar = new f(context, "[DEFAULT]", jVar);
            bVar.put("[DEFAULT]", fVar);
        }
        fVar.f();
        return fVar;
    }

    public final void a() {
        F.i("FirebaseApp was deleted", !this.f4311f.get());
    }

    public final String e() {
        StringBuilder sb = new StringBuilder();
        a();
        byte[] bytes = this.f4308b.getBytes(Charset.defaultCharset());
        sb.append(bytes == null ? null : Base64.encodeToString(bytes, 11));
        sb.append("+");
        a();
        byte[] bytes2 = this.f4309c.f4319b.getBytes(Charset.defaultCharset());
        sb.append(bytes2 != null ? Base64.encodeToString(bytes2, 11) : null);
        return sb.toString();
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof f)) {
            return false;
        }
        f fVar = (f) obj;
        fVar.a();
        return this.f4308b.equals(fVar.f4308b);
    }

    public final void f() {
        HashMap map;
        if (!w.g.a(this.f4307a)) {
            StringBuilder sb = new StringBuilder("Device in Direct Boot Mode: postponing initialization of Firebase APIs for app ");
            a();
            sb.append(this.f4308b);
            Log.i("FirebaseApp", sb.toString());
            Context context = this.f4307a;
            AtomicReference atomicReference = e.f4303b;
            if (atomicReference.get() == null) {
                e eVar = new e(context);
                while (!atomicReference.compareAndSet(null, eVar)) {
                    if (atomicReference.get() != null) {
                        return;
                    }
                }
                context.registerReceiver(eVar, new IntentFilter("android.intent.action.USER_UNLOCKED"));
                return;
            }
            return;
        }
        StringBuilder sb2 = new StringBuilder("Device unlocked: initializing all Firebase APIs for app ");
        a();
        sb2.append(this.f4308b);
        Log.i("FirebaseApp", sb2.toString());
        l1.g gVar = this.f4310d;
        a();
        boolean zEquals = "[DEFAULT]".equals(this.f4308b);
        AtomicReference atomicReference2 = gVar.f5604f;
        Boolean boolValueOf = Boolean.valueOf(zEquals);
        while (true) {
            if (atomicReference2.compareAndSet(null, boolValueOf)) {
                synchronized (gVar) {
                    map = new HashMap(gVar.f5600a);
                }
                gVar.e(map, zEquals);
                break;
            } else if (atomicReference2.get() != null) {
                break;
            }
        }
        ((p1.c) this.f4312g.get()).b();
    }

    public final int hashCode() {
        return this.f4308b.hashCode();
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(this.f4308b, "name");
        rVar.v(this.f4309c, "options");
        return rVar.toString();
    }
}
