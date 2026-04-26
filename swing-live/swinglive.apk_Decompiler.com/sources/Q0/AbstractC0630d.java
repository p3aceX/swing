package q0;

import I.C0053n;
import android.accounts.Account;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.auth.TokenData;
import com.google.android.gms.auth.UserRecoverableAuthException;
import com.google.android.gms.common.GooglePlayServicesIncorrectManifestValueException;
import com.google.android.gms.common.api.j;
import com.google.android.gms.common.internal.AbstractC0289l;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.M;
import com.google.android.gms.common.internal.P;
import com.google.android.gms.common.internal.r;
import com.google.android.gms.internal.auth.zzbw;
import com.google.android.gms.internal.auth.zzby;
import com.google.android.gms.internal.auth.zzdc;
import com.google.android.gms.internal.auth.zzg;
import com.google.android.gms.internal.auth.zzh;
import com.google.android.gms.internal.auth.zzht;
import com.google.android.gms.internal.auth.zzhw;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import z0.AbstractC0778i;
import z0.C0774e;
import z0.C0776g;
import z0.C0777h;
import z0.ServiceConnectionC0770a;

/* JADX INFO: renamed from: q0.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0630d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final String[] f6252a = {"com.google", "com.google.work", "cn.google"};

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final ComponentName f6253b = new ComponentName("com.google.android.gms", "com.google.android.gms.auth.GetToken");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0.a f6254c = new C0.a("Auth", "GoogleAuthUtil");

    public static void a(Context context, String str) throws IOException, B2.a {
        F.f("Calling this from your main thread can lead to deadlock");
        f(context);
        Bundle bundle = new Bundle();
        g(context, bundle);
        zzdc.zzd(context);
        if (zzhw.zze() && i(context)) {
            zzg zzgVarZza = zzh.zza(context);
            zzbw zzbwVar = new zzbw();
            zzbwVar.zza(str);
            try {
                e(zzgVarZza.zza(zzbwVar), "clear token");
                return;
            } catch (j e) {
                f6254c.f("%s failed via GoogleAuthServiceClient, falling back to previous approach:\n%s", "clear token", Log.getStackTraceString(e));
            }
        }
        d(context, f6253b, new r(19, str, bundle));
    }

    public static String b(Context context, Account account, String str) throws IOException, B2.a {
        TokenData tokenDataC;
        C0.a aVar = f6254c;
        Bundle bundle = new Bundle();
        h(account);
        F.f("Calling this from your main thread can lead to deadlock");
        F.e(str, "Scope cannot be empty or null.");
        h(account);
        f(context);
        Bundle bundle2 = new Bundle(bundle);
        g(context, bundle2);
        zzdc.zzd(context);
        if (zzhw.zze() && i(context)) {
            try {
                Bundle bundle3 = (Bundle) e(zzh.zza(context).zzc(account, str, bundle2), "token retrieval");
                if (bundle3 == null) {
                    aVar.f("Service call returned null.", new Object[0]);
                    throw new IOException("Service unavailable.");
                }
                tokenDataC = c(context, bundle3);
            } catch (j e) {
                aVar.f("%s failed via GoogleAuthServiceClient, falling back to previous approach:\n%s", "token retrieval", Log.getStackTraceString(e));
                tokenDataC = (TokenData) d(context, f6253b, new C0053n(account, str, bundle2, context, 15));
            }
        } else {
            tokenDataC = (TokenData) d(context, f6253b, new C0053n(account, str, bundle2, context, 15));
        }
        return tokenDataC.f3311b;
    }

    public static TokenData c(Context context, Bundle bundle) throws IOException, B2.a {
        TokenData tokenData;
        int i4;
        ClassLoader classLoader = TokenData.class.getClassLoader();
        if (classLoader != null) {
            bundle.setClassLoader(classLoader);
        }
        Bundle bundle2 = bundle.getBundle("tokenDetails");
        if (bundle2 == null) {
            tokenData = null;
        } else {
            if (classLoader != null) {
                bundle2.setClassLoader(classLoader);
            }
            tokenData = (TokenData) bundle2.getParcelable("TokenData");
        }
        if (tokenData != null) {
            return tokenData;
        }
        String string = bundle.getString("Error");
        Intent intent = (Intent) bundle.getParcelable("userRecoveryIntent");
        PendingIntent pendingIntent = (PendingIntent) bundle.getParcelable("userRecoveryPendingIntent");
        zzby zzbyVarZza = zzby.zza(string);
        C0.a aVar = f6254c;
        aVar.f("[GoogleAuthUtil] error status:" + zzbyVarZza + " with method:getTokenWithDetails", new Object[0]);
        if (!zzby.BAD_AUTHENTICATION.equals(zzbyVarZza) && !zzby.CAPTCHA.equals(zzbyVarZza) && !zzby.NEED_PERMISSION.equals(zzbyVarZza) && !zzby.NEED_REMOTE_CONSENT.equals(zzbyVarZza) && !zzby.NEEDS_BROWSER.equals(zzbyVarZza) && !zzby.USER_CANCEL.equals(zzbyVarZza) && !zzby.DEVICE_MANAGEMENT_REQUIRED.equals(zzbyVarZza) && !zzby.DM_INTERNAL_ERROR.equals(zzbyVarZza) && !zzby.DM_SYNC_DISABLED.equals(zzbyVarZza) && !zzby.DM_ADMIN_BLOCKED.equals(zzbyVarZza) && !zzby.DM_ADMIN_PENDING_APPROVAL.equals(zzbyVarZza) && !zzby.DM_STALE_SYNC_REQUIRED.equals(zzbyVarZza) && !zzby.DM_DEACTIVATED.equals(zzbyVarZza) && !zzby.DM_REQUIRED.equals(zzbyVarZza) && !zzby.THIRD_PARTY_DEVICE_MANAGEMENT_REQUIRED.equals(zzbyVarZza) && !zzby.DM_SCREENLOCK_REQUIRED.equals(zzbyVarZza)) {
            if (zzby.NETWORK_ERROR.equals(zzbyVarZza) || zzby.SERVICE_UNAVAILABLE.equals(zzbyVarZza) || zzby.INTNERNAL_ERROR.equals(zzbyVarZza) || zzby.AUTH_SECURITY_ERROR.equals(zzbyVarZza) || zzby.ACCOUNT_NOT_PRESENT.equals(zzbyVarZza)) {
                throw new IOException(string);
            }
            throw new B2.a(string);
        }
        zzdc.zzd(context);
        if (!zzht.zzc()) {
            throw new UserRecoverableAuthException(string, intent, 1);
        }
        if (pendingIntent != null && intent != null) {
            throw new UserRecoverableAuthException(string, intent, 2);
        }
        Object obj = C0774e.f6958c;
        int i5 = AbstractC0778i.e;
        try {
            i4 = context.getPackageManager().getPackageInfo("com.google.android.gms", 0).versionCode;
        } catch (PackageManager.NameNotFoundException unused) {
            Log.w("GooglePlayServicesUtil", "Google Play services is missing.");
            i4 = 0;
        }
        if (i4 >= Integer.MAX_VALUE && pendingIntent == null) {
            aVar.c("Recovery PendingIntent is missing on current Gms version: 2147483647 for method: getTokenWithDetails. It should always be present on or above Gms version 2147483647. This indicates a bug in Gms implementation.", new Object[0]);
        }
        if (intent == null) {
            aVar.c(S.g("no recovery Intent found with status=", string, " for method=getTokenWithDetails. This shouldn't happen"), new Object[0]);
        }
        throw new UserRecoverableAuthException(string, intent, 1);
    }

    public static Object d(Context context, ComponentName componentName, InterfaceC0633g interfaceC0633g) throws IOException {
        ServiceConnectionC0770a serviceConnectionC0770a = new ServiceConnectionC0770a();
        P pA = AbstractC0289l.a(context);
        try {
            pA.getClass();
            try {
                if (!pA.c(new M(componentName), serviceConnectionC0770a, "GoogleAuthUtil", null)) {
                    throw new IOException("Could not bind to service.");
                }
                try {
                    return interfaceC0633g.b(serviceConnectionC0770a.a());
                } catch (RemoteException | InterruptedException | TimeoutException e) {
                    Log.i("GoogleAuthUtil", "Error on service connection.", e);
                    throw new IOException("Error on service connection.", e);
                }
            } finally {
                pA.b(new M(componentName), serviceConnectionC0770a);
            }
        } catch (SecurityException e4) {
            Log.w("GoogleAuthUtil", "SecurityException while bind to auth service: " + e4.getMessage());
            throw new IOException("SecurityException while binding to Auth service.", e4);
        }
    }

    public static Object e(Task task, String str) throws j, IOException {
        C0.a aVar = f6254c;
        try {
            return Tasks.await(task);
        } catch (InterruptedException e) {
            String strG = S.g("Interrupted while waiting for the task of ", str, " to finish.");
            aVar.f(strG, new Object[0]);
            throw new IOException(strG, e);
        } catch (CancellationException e4) {
            String strG2 = S.g("Canceled while waiting for the task of ", str, " to finish.");
            aVar.f(strG2, new Object[0]);
            throw new IOException(strG2, e4);
        } catch (ExecutionException e5) {
            Throwable cause = e5.getCause();
            if (cause instanceof j) {
                throw ((j) cause);
            }
            String strG3 = S.g("Unable to get a result for ", str, " due to ExecutionException.");
            aVar.f(strG3, new Object[0]);
            throw new IOException(strG3, e5);
        }
    }

    public static void f(Context context) throws B2.a {
        try {
            AbstractC0778i.a(context.getApplicationContext());
        } catch (GooglePlayServicesIncorrectManifestValueException | C0776g e) {
            throw new B2.a(e.getMessage(), e);
        } catch (C0777h e4) {
            throw new C0631e(e4.getMessage(), new Intent(e4.f6962a), 1);
        }
    }

    public static void g(Context context, Bundle bundle) {
        String str = context.getApplicationInfo().packageName;
        bundle.putString("clientPackageName", str);
        if (TextUtils.isEmpty(bundle.getString("androidPackageName"))) {
            bundle.putString("androidPackageName", str);
        }
        bundle.putLong("service_connection_start_time_millis", SystemClock.elapsedRealtime());
    }

    public static void h(Account account) {
        if (TextUtils.isEmpty(account.name)) {
            throw new IllegalArgumentException("Account name cannot be empty!");
        }
        String[] strArr = f6252a;
        for (int i4 = 0; i4 < 3; i4++) {
            if (strArr[i4].equals(account.type)) {
                return;
            }
        }
        throw new IllegalArgumentException("Account type not supported");
    }

    public static boolean i(Context context) {
        if (C0774e.f6959d.c(context, 17895000) != 0) {
            return false;
        }
        List listZzq = zzhw.zzb().zzq();
        String str = context.getApplicationInfo().packageName;
        Iterator it = listZzq.iterator();
        while (it.hasNext()) {
            if (((String) it.next()).equals(str)) {
                return false;
            }
        }
        return true;
    }
}
