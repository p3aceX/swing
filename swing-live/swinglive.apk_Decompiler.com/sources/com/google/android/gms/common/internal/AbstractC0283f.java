package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.accounts.Account;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Looper;
import android.os.RemoteException;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.api.Scope;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicInteger;
import z0.C0771b;
import z0.C0773d;
import z0.C0774e;
import z0.C0775f;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0283f {
    public static final int CONNECT_STATE_CONNECTED = 4;
    public static final int CONNECT_STATE_DISCONNECTED = 1;
    public static final int CONNECT_STATE_DISCONNECTING = 5;
    public static final String DEFAULT_ACCOUNT = "<<default account>>";
    public static final String KEY_PENDING_INTENT = "pendingIntent";
    private volatile String zzA;
    private C0771b zzB;
    private boolean zzC;
    private volatile L zzD;
    Q zza;
    final Handler zzb;
    protected InterfaceC0281d zzc;
    protected AtomicInteger zzd;
    private int zzf;
    private long zzg;
    private long zzh;
    private int zzi;
    private long zzj;
    private volatile String zzk;
    private final Context zzl;
    private final Looper zzm;
    private final AbstractC0289l zzn;
    private final C0775f zzo;
    private final Object zzp;
    private final Object zzq;
    private InterfaceC0292o zzr;
    private IInterface zzs;
    private final ArrayList zzt;
    private I zzu;
    private int zzv;
    private final InterfaceC0279b zzw;
    private final InterfaceC0280c zzx;
    private final int zzy;
    private final String zzz;
    private static final C0773d[] zze = new C0773d[0];
    public static final String[] GOOGLE_PLUS_REQUIRED_FEATURES = {"service_esmobile", "service_googleme"};

    public AbstractC0283f(Context context, Looper looper, P p4, int i4, t tVar, t tVar2, String str) {
        C0774e c0774e = C0774e.f6959d;
        this.zzk = null;
        this.zzp = new Object();
        this.zzq = new Object();
        this.zzt = new ArrayList();
        this.zzv = 1;
        this.zzB = null;
        this.zzC = false;
        this.zzD = null;
        this.zzd = new AtomicInteger(0);
        F.h(context, "Context must not be null");
        this.zzl = context;
        F.h(looper, "Looper must not be null");
        this.zzm = looper;
        F.h(p4, "Supervisor must not be null");
        this.zzn = p4;
        this.zzo = c0774e;
        this.zzb = new G(this, looper);
        this.zzy = i4;
        this.zzw = tVar;
        this.zzx = tVar2;
        this.zzz = str;
    }

    public static void zzj(AbstractC0283f abstractC0283f, L l2) {
        abstractC0283f.zzD = l2;
        if (abstractC0283f.usesClientTelemetry()) {
            C0286i c0286i = l2.f3533d;
            t tVarB = t.b();
            u uVar = c0286i == null ? null : c0286i.f3563a;
            synchronized (tVarB) {
                if (uVar == null) {
                    tVarB.f3601a = t.f3600c;
                    return;
                }
                u uVar2 = (u) tVarB.f3601a;
                if (uVar2 == null || uVar2.f3602a < uVar.f3602a) {
                    tVarB.f3601a = uVar;
                }
            }
        }
    }

    public static /* bridge */ /* synthetic */ void zzk(AbstractC0283f abstractC0283f, int i4) {
        int i5;
        int i6;
        synchronized (abstractC0283f.zzp) {
            i5 = abstractC0283f.zzv;
        }
        if (i5 == 3) {
            abstractC0283f.zzC = true;
            i6 = 5;
        } else {
            i6 = 4;
        }
        Handler handler = abstractC0283f.zzb;
        handler.sendMessage(handler.obtainMessage(i6, abstractC0283f.zzd.get(), 16));
    }

    public static /* bridge */ /* synthetic */ boolean zzn(AbstractC0283f abstractC0283f, int i4, int i5, IInterface iInterface) {
        synchronized (abstractC0283f.zzp) {
            try {
                if (abstractC0283f.zzv != i4) {
                    return false;
                }
                abstractC0283f.a(i5, iInterface);
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public static /* bridge */ /* synthetic */ boolean zzo(AbstractC0283f abstractC0283f) {
        if (abstractC0283f.zzC || TextUtils.isEmpty(abstractC0283f.getServiceDescriptor()) || TextUtils.isEmpty(abstractC0283f.getLocalStartServiceAction())) {
            return false;
        }
        try {
            Class.forName(abstractC0283f.getServiceDescriptor());
            return true;
        } catch (ClassNotFoundException unused) {
            return false;
        }
    }

    public final void a(int i4, IInterface iInterface) {
        Q q4;
        F.b((i4 == 4) == (iInterface != null));
        synchronized (this.zzp) {
            try {
                this.zzv = i4;
                this.zzs = iInterface;
                if (i4 == 1) {
                    I i5 = this.zzu;
                    if (i5 != null) {
                        AbstractC0289l abstractC0289l = this.zzn;
                        String str = this.zza.f3550a;
                        F.g(str);
                        String str2 = this.zza.f3551b;
                        zze();
                        boolean z4 = this.zza.f3552c;
                        abstractC0289l.getClass();
                        abstractC0289l.b(new M(str, str2, z4), i5);
                        this.zzu = null;
                    }
                } else if (i4 == 2 || i4 == 3) {
                    I i6 = this.zzu;
                    if (i6 != null && (q4 = this.zza) != null) {
                        Log.e("GmsClient", "Calling connect() while still connected, missing disconnect() for " + q4.f3550a + " on " + q4.f3551b);
                        AbstractC0289l abstractC0289l2 = this.zzn;
                        String str3 = this.zza.f3550a;
                        F.g(str3);
                        String str4 = this.zza.f3551b;
                        zze();
                        boolean z5 = this.zza.f3552c;
                        abstractC0289l2.getClass();
                        abstractC0289l2.b(new M(str3, str4, z5), i6);
                        this.zzd.incrementAndGet();
                    }
                    I i7 = new I(this, this.zzd.get());
                    this.zzu = i7;
                    Q q5 = (this.zzv != 3 || getLocalStartServiceAction() == null) ? new Q(getStartServicePackage(), getStartServiceAction(), getUseDynamicLookup()) : new Q(getContext().getPackageName(), getLocalStartServiceAction(), false);
                    this.zza = q5;
                    if (q5.f3552c && getMinApkVersion() < 17895000) {
                        throw new IllegalStateException("Internal Error, the minimum apk version of this BaseGmsClient is too low to support dynamic lookup. Start service action: ".concat(String.valueOf(this.zza.f3550a)));
                    }
                    AbstractC0289l abstractC0289l3 = this.zzn;
                    String str5 = this.zza.f3550a;
                    F.g(str5);
                    if (!abstractC0289l3.c(new M(str5, this.zza.f3551b, this.zza.f3552c), i7, zze(), getBindServiceExecutor())) {
                        Q q6 = this.zza;
                        Log.w("GmsClient", "unable to connect to service: " + q6.f3550a + " on " + q6.f3551b);
                        zzl(16, null, this.zzd.get());
                    }
                } else if (i4 == 4) {
                    F.g(iInterface);
                    onConnectedLocked(iInterface);
                }
            } finally {
            }
        }
    }

    public void checkAvailabilityAndConnect() {
        int iC = this.zzo.c(this.zzl, getMinApkVersion());
        if (iC == 0) {
            connect(new t(this));
        } else {
            a(1, null);
            triggerNotAvailable(new t(this), iC, null);
        }
    }

    public final void checkConnected() {
        if (!isConnected()) {
            throw new IllegalStateException("Not connected. Call connect() and wait for onConnected() to be called.");
        }
    }

    public void connect(InterfaceC0281d interfaceC0281d) {
        F.h(interfaceC0281d, "Connection progress callbacks cannot be null.");
        this.zzc = interfaceC0281d;
        a(2, null);
    }

    public abstract IInterface createServiceInterface(IBinder iBinder);

    public void disconnect() {
        this.zzd.incrementAndGet();
        synchronized (this.zzt) {
            try {
                int size = this.zzt.size();
                for (int i4 = 0; i4 < size; i4++) {
                    C c5 = (C) this.zzt.get(i4);
                    synchronized (c5) {
                        c5.f3513a = null;
                    }
                }
                this.zzt.clear();
            } catch (Throwable th) {
                throw th;
            }
        }
        synchronized (this.zzq) {
            this.zzr = null;
        }
        a(1, null);
    }

    public void dump(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
        int i4;
        IInterface iInterface;
        InterfaceC0292o interfaceC0292o;
        synchronized (this.zzp) {
            i4 = this.zzv;
            iInterface = this.zzs;
        }
        synchronized (this.zzq) {
            interfaceC0292o = this.zzr;
        }
        printWriter.append((CharSequence) str).append("mConnectState=");
        if (i4 == 1) {
            printWriter.print("DISCONNECTED");
        } else if (i4 == 2) {
            printWriter.print("REMOTE_CONNECTING");
        } else if (i4 == 3) {
            printWriter.print("LOCAL_CONNECTING");
        } else if (i4 == 4) {
            printWriter.print("CONNECTED");
        } else if (i4 != 5) {
            printWriter.print("UNKNOWN");
        } else {
            printWriter.print("DISCONNECTING");
        }
        printWriter.append(" mService=");
        if (iInterface == null) {
            printWriter.append("null");
        } else {
            printWriter.append((CharSequence) getServiceDescriptor()).append("@").append((CharSequence) Integer.toHexString(System.identityHashCode(iInterface.asBinder())));
        }
        printWriter.append(" mServiceBroker=");
        if (interfaceC0292o == null) {
            printWriter.println("null");
        } else {
            printWriter.append("IGmsServiceBroker@").println(Integer.toHexString(System.identityHashCode(((E) interfaceC0292o).asBinder())));
        }
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US);
        if (this.zzh > 0) {
            PrintWriter printWriterAppend = printWriter.append((CharSequence) str).append("lastConnectedTime=");
            long j4 = this.zzh;
            printWriterAppend.println(j4 + " " + simpleDateFormat.format(new Date(j4)));
        }
        if (this.zzg > 0) {
            printWriter.append((CharSequence) str).append("lastSuspendedCause=");
            int i5 = this.zzf;
            if (i5 == 1) {
                printWriter.append("CAUSE_SERVICE_DISCONNECTED");
            } else if (i5 == 2) {
                printWriter.append("CAUSE_NETWORK_LOST");
            } else if (i5 != 3) {
                printWriter.append((CharSequence) String.valueOf(i5));
            } else {
                printWriter.append("CAUSE_DEAD_OBJECT_EXCEPTION");
            }
            PrintWriter printWriterAppend2 = printWriter.append(" lastSuspendedTime=");
            long j5 = this.zzg;
            printWriterAppend2.println(j5 + " " + simpleDateFormat.format(new Date(j5)));
        }
        if (this.zzj > 0) {
            printWriter.append((CharSequence) str).append("lastFailedStatus=").append((CharSequence) AbstractC0184a.L(this.zzi));
            PrintWriter printWriterAppend3 = printWriter.append(" lastFailedTime=");
            long j6 = this.zzj;
            printWriterAppend3.println(j6 + " " + simpleDateFormat.format(new Date(j6)));
        }
    }

    public boolean enableLocalFallback() {
        return false;
    }

    public abstract Account getAccount();

    public C0773d[] getApiFeatures() {
        return zze;
    }

    public final C0773d[] getAvailableFeatures() {
        L l2 = this.zzD;
        if (l2 == null) {
            return null;
        }
        return l2.f3531b;
    }

    public abstract Executor getBindServiceExecutor();

    public Bundle getConnectionHint() {
        return null;
    }

    public final Context getContext() {
        return this.zzl;
    }

    public String getEndpointPackageName() {
        Q q4;
        if (!isConnected() || (q4 = this.zza) == null) {
            throw new RuntimeException("Failed to connect when checking package");
        }
        return q4.f3551b;
    }

    public int getGCoreServiceId() {
        return this.zzy;
    }

    public Bundle getGetServiceRequestExtraArgs() {
        return new Bundle();
    }

    public String getLastDisconnectMessage() {
        return this.zzk;
    }

    public String getLocalStartServiceAction() {
        return null;
    }

    public final Looper getLooper() {
        return this.zzm;
    }

    public abstract int getMinApkVersion();

    public void getRemoteService(InterfaceC0290m interfaceC0290m, Set<Scope> set) {
        Bundle getServiceRequestExtraArgs = getGetServiceRequestExtraArgs();
        int i4 = this.zzy;
        String str = this.zzA;
        int i5 = C0775f.f6960a;
        Scope[] scopeArr = C0287j.f3568u;
        Bundle bundle = new Bundle();
        C0773d[] c0773dArr = C0287j.v;
        C0287j c0287j = new C0287j(6, i4, i5, null, null, scopeArr, bundle, null, c0773dArr, c0773dArr, true, 0, false, str);
        c0287j.f3572d = this.zzl.getPackageName();
        c0287j.f3574m = getServiceRequestExtraArgs;
        if (set != null) {
            c0287j.f3573f = (Scope[]) set.toArray(new Scope[0]);
        }
        if (requiresSignIn()) {
            Account account = getAccount();
            if (account == null) {
                account = new Account(DEFAULT_ACCOUNT, "com.google");
            }
            c0287j.f3575n = account;
            if (interfaceC0290m != null) {
                c0287j.e = interfaceC0290m.asBinder();
            }
        } else if (requiresAccount()) {
            c0287j.f3575n = getAccount();
        }
        c0287j.f3576o = zze;
        c0287j.f3577p = getApiFeatures();
        if (usesClientTelemetry()) {
            c0287j.f3580s = true;
        }
        try {
            synchronized (this.zzq) {
                try {
                    InterfaceC0292o interfaceC0292o = this.zzr;
                    if (interfaceC0292o != null) {
                        ((E) interfaceC0292o).a(new H(this, this.zzd.get()), c0287j);
                    } else {
                        Log.w("GmsClient", "mServiceBroker is null, client disconnected");
                    }
                } finally {
                }
            }
        } catch (DeadObjectException e) {
            Log.w("GmsClient", "IGmsServiceBroker.getService failed", e);
            triggerConnectionSuspended(3);
        } catch (RemoteException e4) {
            e = e4;
            Log.w("GmsClient", "IGmsServiceBroker.getService failed", e);
            onPostInitHandler(8, null, null, this.zzd.get());
        } catch (SecurityException e5) {
            throw e5;
        } catch (RuntimeException e6) {
            e = e6;
            Log.w("GmsClient", "IGmsServiceBroker.getService failed", e);
            onPostInitHandler(8, null, null, this.zzd.get());
        }
    }

    public abstract Set getScopes();

    public final IInterface getService() {
        IInterface iInterface;
        synchronized (this.zzp) {
            try {
                if (this.zzv == 5) {
                    throw new DeadObjectException();
                }
                checkConnected();
                iInterface = this.zzs;
                F.h(iInterface, "Client is connected but service is null");
            } catch (Throwable th) {
                throw th;
            }
        }
        return iInterface;
    }

    public IBinder getServiceBrokerBinder() {
        synchronized (this.zzq) {
            try {
                InterfaceC0292o interfaceC0292o = this.zzr;
                if (interfaceC0292o == null) {
                    return null;
                }
                return ((E) interfaceC0292o).asBinder();
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public abstract String getServiceDescriptor();

    public Intent getSignInIntent() {
        throw new UnsupportedOperationException("Not a sign in API");
    }

    public abstract String getStartServiceAction();

    public String getStartServicePackage() {
        return "com.google.android.gms";
    }

    public C0286i getTelemetryConfiguration() {
        L l2 = this.zzD;
        if (l2 == null) {
            return null;
        }
        return l2.f3533d;
    }

    public boolean getUseDynamicLookup() {
        return getMinApkVersion() >= 211700000;
    }

    public boolean hasConnectionInfo() {
        return this.zzD != null;
    }

    public boolean isConnected() {
        boolean z4;
        synchronized (this.zzp) {
            z4 = this.zzv == 4;
        }
        return z4;
    }

    public boolean isConnecting() {
        boolean z4;
        synchronized (this.zzp) {
            int i4 = this.zzv;
            z4 = true;
            if (i4 != 2 && i4 != 3) {
                z4 = false;
            }
        }
        return z4;
    }

    public void onConnectedLocked(IInterface iInterface) {
        this.zzh = System.currentTimeMillis();
    }

    public void onConnectionFailed(C0771b c0771b) {
        this.zzi = c0771b.f6949b;
        this.zzj = System.currentTimeMillis();
    }

    public void onConnectionSuspended(int i4) {
        this.zzf = i4;
        this.zzg = System.currentTimeMillis();
    }

    public void onPostInitHandler(int i4, IBinder iBinder, Bundle bundle, int i5) {
        Handler handler = this.zzb;
        handler.sendMessage(handler.obtainMessage(1, i5, -1, new J(this, i4, iBinder, bundle)));
    }

    public void onUserSignOut(InterfaceC0282e interfaceC0282e) {
        B.k kVar = (B.k) interfaceC0282e;
        ((com.google.android.gms.common.api.internal.E) kVar.f104b).f3404m.f3481n.post(new F.b(kVar, 10));
    }

    public boolean providesSignIn() {
        return false;
    }

    public boolean requiresAccount() {
        return false;
    }

    public boolean requiresGooglePlayServices() {
        return true;
    }

    public boolean requiresSignIn() {
        return false;
    }

    public void setAttributionTag(String str) {
        this.zzA = str;
    }

    public void triggerConnectionSuspended(int i4) {
        Handler handler = this.zzb;
        handler.sendMessage(handler.obtainMessage(6, this.zzd.get(), i4));
    }

    public void triggerNotAvailable(InterfaceC0281d interfaceC0281d, int i4, PendingIntent pendingIntent) {
        F.h(interfaceC0281d, "Connection progress callbacks cannot be null.");
        this.zzc = interfaceC0281d;
        Handler handler = this.zzb;
        handler.sendMessage(handler.obtainMessage(3, this.zzd.get(), i4, pendingIntent));
    }

    public boolean usesClientTelemetry() {
        return false;
    }

    public final String zze() {
        String str = this.zzz;
        return str == null ? this.zzl.getClass().getName() : str;
    }

    public final void zzl(int i4, Bundle bundle, int i5) {
        Handler handler = this.zzb;
        handler.sendMessage(handler.obtainMessage(7, i5, -1, new K(this, i4)));
    }

    public void disconnect(String str) {
        this.zzk = str;
        disconnect();
    }
}
