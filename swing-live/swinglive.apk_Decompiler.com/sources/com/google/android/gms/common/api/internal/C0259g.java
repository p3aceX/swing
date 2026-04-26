package com.google.android.gms.common.api.internal;

import android.app.ActivityManager;
import android.app.Application;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.util.SparseIntArray;
import com.google.android.gms.common.api.GoogleApiActivity;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.AbstractC0289l;
import com.google.android.gms.common.internal.C0294q;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.base.zad;
import com.google.android.gms.internal.base.zal;
import com.google.android.gms.internal.base.zaq;
import com.google.android.gms.internal.common.zzd;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import u1.C0690c;
import z0.AbstractC0778i;
import z0.C0771b;
import z0.C0773d;
import z0.C0774e;
import z0.C0775f;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0259g implements Handler.Callback {

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final Status f3465p = new Status(4, "Sign-out occurred while this API call was in progress.");

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final Status f3466q = new Status(4, "The user must be signed in to make this API call.");

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final Object f3467r = new Object();

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static C0259g f3468s;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public long f3469a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f3470b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public com.google.android.gms.common.internal.v f3471c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public B0.c f3472d;
    public final Context e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0774e f3473f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final com.google.android.gms.common.internal.r f3474g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final AtomicInteger f3475h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final AtomicInteger f3476i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final ConcurrentHashMap f3477j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public DialogInterfaceOnCancelListenerC0277z f3478k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final n.c f3479l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final n.c f3480m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final zaq f3481n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public volatile boolean f3482o;

    public C0259g(Context context, Looper looper) {
        C0774e c0774e = C0774e.f6959d;
        this.f3469a = 10000L;
        this.f3470b = false;
        this.f3475h = new AtomicInteger(1);
        this.f3476i = new AtomicInteger(0);
        this.f3477j = new ConcurrentHashMap(5, 0.75f, 1);
        this.f3478k = null;
        this.f3479l = new n.c(0);
        this.f3480m = new n.c(0);
        this.f3482o = true;
        this.e = context;
        zaq zaqVar = new zaq(looper, this);
        this.f3481n = zaqVar;
        this.f3473f = c0774e;
        this.f3474g = new com.google.android.gms.common.internal.r(2);
        PackageManager packageManager = context.getPackageManager();
        if (G0.a.e == null) {
            G0.a.e = Boolean.valueOf(Build.VERSION.SDK_INT >= 26 && packageManager.hasSystemFeature("android.hardware.type.automotive"));
        }
        if (G0.a.e.booleanValue()) {
            this.f3482o = false;
        }
        zaqVar.sendMessage(zaqVar.obtainMessage(6));
    }

    public static void a() {
        synchronized (f3467r) {
            try {
                C0259g c0259g = f3468s;
                if (c0259g != null) {
                    c0259g.f3476i.incrementAndGet();
                    zaq zaqVar = c0259g.f3481n;
                    zaqVar.sendMessageAtFrontOfQueue(zaqVar.obtainMessage(10));
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public static Status e(C0253a c0253a, C0771b c0771b) {
        String str = c0253a.f3450b.f3384c;
        String strValueOf = String.valueOf(c0771b);
        StringBuilder sb = new StringBuilder(String.valueOf(str).length() + 63 + strValueOf.length());
        sb.append("API: ");
        sb.append(str);
        sb.append(" is not available on this device. Connection failed with: ");
        sb.append(strValueOf);
        return new Status(1, 17, sb.toString(), c0771b.f6950c, c0771b);
    }

    public static C0259g g(Context context) {
        C0259g c0259g;
        HandlerThread handlerThread;
        synchronized (f3467r) {
            if (f3468s == null) {
                synchronized (AbstractC0289l.f3582a) {
                    try {
                        handlerThread = AbstractC0289l.f3584c;
                        if (handlerThread == null) {
                            HandlerThread handlerThread2 = new HandlerThread("GoogleApiHandler", 9);
                            AbstractC0289l.f3584c = handlerThread2;
                            handlerThread2.start();
                            handlerThread = AbstractC0289l.f3584c;
                        }
                    } finally {
                    }
                }
                Looper looper = handlerThread.getLooper();
                Context applicationContext = context.getApplicationContext();
                Object obj = C0774e.f6958c;
                f3468s = new C0259g(applicationContext, looper);
            }
            c0259g = f3468s;
        }
        return c0259g;
    }

    public final void b(DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z) {
        synchronized (f3467r) {
            try {
                if (this.f3478k != dialogInterfaceOnCancelListenerC0277z) {
                    this.f3478k = dialogInterfaceOnCancelListenerC0277z;
                    this.f3479l.clear();
                }
                this.f3479l.addAll(dialogInterfaceOnCancelListenerC0277z.e);
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final boolean c() {
        if (this.f3470b) {
            return false;
        }
        com.google.android.gms.common.internal.u uVar = (com.google.android.gms.common.internal.u) com.google.android.gms.common.internal.t.b().f3601a;
        if (uVar != null && !uVar.f3603b) {
            return false;
        }
        int i4 = ((SparseIntArray) this.f3474g.f3597b).get(203400000, -1);
        return i4 == -1 || i4 == 0;
    }

    public final boolean d(C0771b c0771b, int i4) {
        boolean zBooleanValue;
        PendingIntent activity;
        Boolean bool;
        C0774e c0774e = this.f3473f;
        Context context = this.e;
        c0774e.getClass();
        synchronized (H0.a.class) {
            Context applicationContext = context.getApplicationContext();
            Context context2 = H0.a.f508a;
            if (context2 == null || (bool = H0.a.f509b) == null || context2 != applicationContext) {
                H0.a.f509b = null;
                if (Build.VERSION.SDK_INT >= 26) {
                    H0.a.f509b = Boolean.valueOf(applicationContext.getPackageManager().isInstantApp());
                } else {
                    try {
                        context.getClassLoader().loadClass("com.google.android.instantapps.supervisor.InstantAppsRuntime");
                        H0.a.f509b = Boolean.TRUE;
                    } catch (ClassNotFoundException unused) {
                        H0.a.f509b = Boolean.FALSE;
                    }
                }
                H0.a.f508a = applicationContext;
                zBooleanValue = H0.a.f509b.booleanValue();
            } else {
                zBooleanValue = bool.booleanValue();
            }
        }
        if (!zBooleanValue) {
            int i5 = c0771b.f6949b;
            if (i5 == 0 || (activity = c0771b.f6950c) == null) {
                Intent intentA = c0774e.a(context, i5, null);
                activity = intentA != null ? PendingIntent.getActivity(context, 0, intentA, zzd.zza | 134217728) : null;
            }
            if (activity != null) {
                int i6 = c0771b.f6949b;
                int i7 = GoogleApiActivity.f3368b;
                Intent intent = new Intent(context, (Class<?>) GoogleApiActivity.class);
                intent.putExtra("pending_intent", activity);
                intent.putExtra("failing_client_id", i4);
                intent.putExtra("notify_manager", true);
                c0774e.g(context, i6, zal.zaa(context, 0, intent, zal.zaa | 134217728));
                return true;
            }
        }
        return false;
    }

    public final E f(com.google.android.gms.common.api.l lVar) {
        C0253a apiKey = lVar.getApiKey();
        ConcurrentHashMap concurrentHashMap = this.f3477j;
        E e = (E) concurrentHashMap.get(apiKey);
        if (e == null) {
            e = new E(this, lVar);
            concurrentHashMap.put(apiKey, e);
        }
        if (e.f3394b.requiresSignIn()) {
            this.f3480m.add(apiKey);
        }
        e.n();
        return e;
    }

    public final void h(C0771b c0771b, int i4) {
        if (d(c0771b, i4)) {
            return;
        }
        zaq zaqVar = this.f3481n;
        zaqVar.sendMessage(zaqVar.obtainMessage(5, i4, 0, c0771b));
    }

    @Override // android.os.Handler.Callback
    public final boolean handleMessage(Message message) {
        C0773d[] c0773dArrG;
        int i4 = message.what;
        zaq zaqVar = this.f3481n;
        ConcurrentHashMap concurrentHashMap = this.f3477j;
        com.google.android.gms.common.internal.w wVar = com.google.android.gms.common.internal.w.f3608a;
        E e = null;
        int i5 = 0;
        int i6 = 1;
        switch (i4) {
            case 1:
                this.f3469a = true == ((Boolean) message.obj).booleanValue() ? 10000L : 300000L;
                zaqVar.removeMessages(12);
                Iterator it = concurrentHashMap.keySet().iterator();
                while (it.hasNext()) {
                    zaqVar.sendMessageDelayed(zaqVar.obtainMessage(12, (C0253a) it.next()), this.f3469a);
                }
                return true;
            case 2:
                message.obj.getClass();
                throw new ClassCastException();
            case 3:
                for (E e4 : concurrentHashMap.values()) {
                    com.google.android.gms.common.internal.F.c(e4.f3404m.f3481n);
                    e4.f3402k = null;
                    e4.n();
                }
                return true;
            case 4:
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
            case 13:
                N n4 = (N) message.obj;
                E eF = (E) concurrentHashMap.get(n4.f3425c.getApiKey());
                if (eF == null) {
                    eF = f(n4.f3425c);
                }
                boolean zRequiresSignIn = eF.f3394b.requiresSignIn();
                X x4 = n4.f3423a;
                if (!zRequiresSignIn || this.f3476i.get() == n4.f3424b) {
                    eF.o(x4);
                    return true;
                }
                x4.a(f3465p);
                eF.q();
                return true;
            case 5:
                int i7 = message.arg1;
                C0771b c0771b = (C0771b) message.obj;
                Iterator it2 = concurrentHashMap.values().iterator();
                while (true) {
                    if (it2.hasNext()) {
                        E e5 = (E) it2.next();
                        if (e5.f3398g == i7) {
                            e = e5;
                        }
                    }
                }
                if (e == null) {
                    StringBuilder sb = new StringBuilder(76);
                    sb.append("Could not find API instance ");
                    sb.append(i7);
                    sb.append(" while trying to fail enqueued calls.");
                    Log.wtf("GoogleApiManager", sb.toString(), new Exception());
                    return true;
                }
                int i8 = c0771b.f6949b;
                if (i8 != 13) {
                    e.e(e(e.f3395c, c0771b));
                    return true;
                }
                this.f3473f.getClass();
                int i9 = AbstractC0778i.e;
                String strB = C0771b.b(i8);
                int length = String.valueOf(strB).length();
                String str = c0771b.f6951d;
                StringBuilder sb2 = new StringBuilder(length + 69 + String.valueOf(str).length());
                sb2.append("Error resolution was canceled by the user, original error message: ");
                sb2.append(strB);
                sb2.append(": ");
                sb2.append(str);
                e.e(new Status(17, sb2.toString()));
                return true;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                Context context = this.e;
                if (context.getApplicationContext() instanceof Application) {
                    ComponentCallbacks2C0255c.b((Application) context.getApplicationContext());
                    ComponentCallbacks2C0255c componentCallbacks2C0255c = ComponentCallbacks2C0255c.e;
                    componentCallbacks2C0255c.a(new C(this, i5));
                    AtomicBoolean atomicBoolean = componentCallbacks2C0255c.f3458b;
                    boolean z4 = atomicBoolean.get();
                    AtomicBoolean atomicBoolean2 = componentCallbacks2C0255c.f3457a;
                    if (!z4) {
                        ActivityManager.RunningAppProcessInfo runningAppProcessInfo = new ActivityManager.RunningAppProcessInfo();
                        ActivityManager.getMyMemoryState(runningAppProcessInfo);
                        if (!atomicBoolean.getAndSet(true) && runningAppProcessInfo.importance > 100) {
                            atomicBoolean2.set(true);
                        }
                    }
                    if (!atomicBoolean2.get()) {
                        this.f3469a = 300000L;
                        return true;
                    }
                }
                return true;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                f((com.google.android.gms.common.api.l) message.obj);
                return true;
            case 9:
                if (concurrentHashMap.containsKey(message.obj)) {
                    E e6 = (E) concurrentHashMap.get(message.obj);
                    com.google.android.gms.common.internal.F.c(e6.f3404m.f3481n);
                    if (e6.f3400i) {
                        e6.n();
                        return true;
                    }
                }
                return true;
            case 10:
                n.c cVar = this.f3480m;
                Iterator it3 = cVar.iterator();
                while (true) {
                    n.g gVar = (n.g) it3;
                    if (!gVar.hasNext()) {
                        cVar.clear();
                        return true;
                    }
                    E e7 = (E) concurrentHashMap.remove((C0253a) gVar.next());
                    if (e7 != null) {
                        e7.q();
                    }
                }
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                if (concurrentHashMap.containsKey(message.obj)) {
                    E e8 = (E) concurrentHashMap.get(message.obj);
                    C0259g c0259g = e8.f3404m;
                    com.google.android.gms.common.internal.F.c(c0259g.f3481n);
                    boolean z5 = e8.f3400i;
                    if (z5) {
                        if (z5) {
                            C0259g c0259g2 = e8.f3404m;
                            zaq zaqVar2 = c0259g2.f3481n;
                            C0253a c0253a = e8.f3395c;
                            zaqVar2.removeMessages(11, c0253a);
                            c0259g2.f3481n.removeMessages(9, c0253a);
                            e8.f3400i = false;
                        }
                        e8.e(c0259g.f3473f.c(c0259g.e, C0775f.f6960a) == 18 ? new Status(21, "Connection timed out waiting for Google Play services update to complete.") : new Status(22, "API failed to connect while resuming due to an unknown error."));
                        e8.f3394b.disconnect("Timing out connection while resuming.");
                        return true;
                    }
                }
                return true;
            case 12:
                if (concurrentHashMap.containsKey(message.obj)) {
                    ((E) concurrentHashMap.get(message.obj)).m(true);
                    return true;
                }
                return true;
            case 14:
                A a5 = (A) message.obj;
                C0253a c0253a2 = a5.f3385a;
                boolean zContainsKey = concurrentHashMap.containsKey(c0253a2);
                TaskCompletionSource taskCompletionSource = a5.f3386b;
                if (zContainsKey) {
                    taskCompletionSource.setResult(Boolean.valueOf(((E) concurrentHashMap.get(c0253a2)).m(false)));
                    return true;
                }
                taskCompletionSource.setResult(Boolean.FALSE);
                return true;
            case 15:
                F f4 = (F) message.obj;
                if (concurrentHashMap.containsKey(f4.f3405a)) {
                    E e9 = (E) concurrentHashMap.get(f4.f3405a);
                    if (e9.f3401j.contains(f4) && !e9.f3400i) {
                        if (e9.f3394b.isConnected()) {
                            e9.g();
                            return true;
                        }
                        e9.n();
                        return true;
                    }
                }
                return true;
            case 16:
                F f5 = (F) message.obj;
                if (concurrentHashMap.containsKey(f5.f3405a)) {
                    E e10 = (E) concurrentHashMap.get(f5.f3405a);
                    if (e10.f3401j.remove(f5)) {
                        C0259g c0259g3 = e10.f3404m;
                        c0259g3.f3481n.removeMessages(15, f5);
                        c0259g3.f3481n.removeMessages(16, f5);
                        LinkedList linkedList = e10.f3393a;
                        ArrayList arrayList = new ArrayList(linkedList.size());
                        Iterator it4 = linkedList.iterator();
                        while (true) {
                            boolean zHasNext = it4.hasNext();
                            C0773d c0773d = f5.f3406b;
                            if (zHasNext) {
                                X x5 = (X) it4.next();
                                if ((x5 instanceof K) && (c0773dArrG = ((K) x5).g(e10)) != null) {
                                    int length2 = c0773dArrG.length;
                                    int i10 = 0;
                                    while (true) {
                                        if (i10 >= length2) {
                                        }
                                        if (!com.google.android.gms.common.internal.F.j(c0773dArrG[i10], c0773d)) {
                                            i10++;
                                        } else if (i10 >= 0) {
                                            arrayList.add(x5);
                                        }
                                        break;
                                    }
                                }
                            } else {
                                int size = arrayList.size();
                                while (i5 < size) {
                                    X x6 = (X) arrayList.get(i5);
                                    linkedList.remove(x6);
                                    x6.b(new com.google.android.gms.common.api.w(c0773d));
                                    i5++;
                                }
                            }
                        }
                    }
                }
                return true;
            case 17:
                com.google.android.gms.common.internal.v vVar = this.f3471c;
                if (vVar != null) {
                    if (vVar.f3606a > 0 || c()) {
                        if (this.f3472d == null) {
                            this.f3472d = new B0.c(this.e, null, B0.c.f106a, wVar, com.google.android.gms.common.api.k.f3499c);
                        }
                        B0.c cVar2 = this.f3472d;
                        cVar2.getClass();
                        D2.C cA = AbstractC0273v.a();
                        cA.f160d = new C0773d[]{zad.zaa};
                        cA.f157a = false;
                        cA.f159c = new C0690c(vVar, i6);
                        cVar2.doBestEffortWrite(cA.a());
                    }
                    this.f3471c = null;
                    return true;
                }
                return true;
            case 18:
                M m4 = (M) message.obj;
                long j4 = m4.f3421c;
                C0294q c0294q = m4.f3419a;
                int i11 = m4.f3420b;
                if (j4 == 0) {
                    com.google.android.gms.common.internal.v vVar2 = new com.google.android.gms.common.internal.v(i11, Arrays.asList(c0294q));
                    if (this.f3472d == null) {
                        this.f3472d = new B0.c(this.e, null, B0.c.f106a, wVar, com.google.android.gms.common.api.k.f3499c);
                    }
                    B0.c cVar3 = this.f3472d;
                    cVar3.getClass();
                    D2.C cA2 = AbstractC0273v.a();
                    cA2.f160d = new C0773d[]{zad.zaa};
                    cA2.f157a = false;
                    cA2.f159c = new C0690c(vVar2, i6);
                    cVar3.doBestEffortWrite(cA2.a());
                    return true;
                }
                com.google.android.gms.common.internal.v vVar3 = this.f3471c;
                if (vVar3 != null) {
                    List list = vVar3.f3607b;
                    if (vVar3.f3606a != i11 || (list != null && list.size() >= m4.f3422d)) {
                        zaqVar.removeMessages(17);
                        com.google.android.gms.common.internal.v vVar4 = this.f3471c;
                        if (vVar4 != null) {
                            if (vVar4.f3606a > 0 || c()) {
                                if (this.f3472d == null) {
                                    this.f3472d = new B0.c(this.e, null, B0.c.f106a, wVar, com.google.android.gms.common.api.k.f3499c);
                                }
                                B0.c cVar4 = this.f3472d;
                                cVar4.getClass();
                                D2.C cA3 = AbstractC0273v.a();
                                cA3.f160d = new C0773d[]{zad.zaa};
                                cA3.f157a = false;
                                cA3.f159c = new C0690c(vVar4, i6);
                                cVar4.doBestEffortWrite(cA3.a());
                            }
                            this.f3471c = null;
                        }
                    } else {
                        com.google.android.gms.common.internal.v vVar5 = this.f3471c;
                        if (vVar5.f3607b == null) {
                            vVar5.f3607b = new ArrayList();
                        }
                        vVar5.f3607b.add(c0294q);
                    }
                }
                if (this.f3471c == null) {
                    ArrayList arrayList2 = new ArrayList();
                    arrayList2.add(c0294q);
                    this.f3471c = new com.google.android.gms.common.internal.v(i11, arrayList2);
                    zaqVar.sendMessageDelayed(zaqVar.obtainMessage(17), m4.f3421c);
                    return true;
                }
                return true;
            case 19:
                this.f3470b = false;
                return true;
            default:
                StringBuilder sb3 = new StringBuilder(31);
                sb3.append("Unknown message id: ");
                sb3.append(i4);
                Log.w("GoogleApiManager", sb3.toString());
                return false;
        }
    }
}
