package y0;

import X.N;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Binder;
import android.os.Build;
import android.os.Looper;
import android.os.Parcel;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.RevocationBoundService;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.p000authapi.zbb;
import org.json.JSONException;
import s0.AbstractC0660a;
import x0.C0713a;
import z0.AbstractC0778i;
import z0.C0779j;

/* JADX INFO: renamed from: y0.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class BinderC0750n extends zbb {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final RevocationBoundService f6834a;

    public BinderC0750n(RevocationBoundService revocationBoundService) {
        super("com.google.android.gms.auth.api.signin.internal.IRevocationService");
        this.f6834a = revocationBoundService;
    }

    public final void a() {
        AppOpsManager appOpsManager;
        int callingUid = Binder.getCallingUid();
        RevocationBoundService revocationBoundService = this.f6834a;
        H0.b bVarA = H0.c.a(revocationBoundService);
        bVarA.getClass();
        try {
            appOpsManager = (AppOpsManager) bVarA.f515a.getSystemService("appops");
        } catch (SecurityException unused) {
        }
        if (appOpsManager == null) {
            throw new NullPointerException("context.getSystemService(Context.APP_OPS_SERVICE) is null");
        }
        appOpsManager.checkPackage(callingUid, "com.google.android.gms");
        try {
            PackageInfo packageInfo = revocationBoundService.getPackageManager().getPackageInfo("com.google.android.gms", 64);
            C0779j c0779jR = C0779j.r(revocationBoundService);
            c0779jR.getClass();
            if (packageInfo != null) {
                if (C0779j.v(packageInfo, false)) {
                    return;
                }
                if (C0779j.v(packageInfo, true)) {
                    Context context = (Context) c0779jR.f6969b;
                    try {
                        if (!AbstractC0778i.f6965c) {
                            try {
                                PackageInfo packageInfo2 = H0.c.a(context).f515a.getPackageManager().getPackageInfo("com.google.android.gms", 64);
                                C0779j.r(context);
                                if (packageInfo2 == null || C0779j.v(packageInfo2, false) || !C0779j.v(packageInfo2, true)) {
                                    AbstractC0778i.f6964b = false;
                                } else {
                                    AbstractC0778i.f6964b = true;
                                }
                                AbstractC0778i.f6965c = true;
                            } catch (PackageManager.NameNotFoundException e) {
                                Log.w("GooglePlayServicesUtil", "Cannot find Google Play services package name.", e);
                                AbstractC0778i.f6965c = true;
                            }
                        }
                        if (AbstractC0778i.f6964b || !"user".equals(Build.TYPE)) {
                            return;
                        } else {
                            Log.w("GoogleSignatureVerifier", "Test-keys aren't accepted on this build.");
                        }
                    } catch (Throwable th) {
                        AbstractC0778i.f6965c = true;
                        throw th;
                    }
                }
            }
        } catch (PackageManager.NameNotFoundException unused2) {
            if (Log.isLoggable("UidVerifier", 3)) {
                Log.d("UidVerifier", "Package manager can't find google play services package, defaulting to false");
            }
        }
        throw new SecurityException(B1.a.l("Calling UID ", Binder.getCallingUid(), " is not Google Play services."));
    }

    @Override // com.google.android.gms.internal.p000authapi.zbb
    public final boolean zba(int i4, Parcel parcel, Parcel parcel2, int i5) {
        GoogleSignInOptions googleSignInOptionsC;
        String strD;
        RevocationBoundService revocationBoundService = this.f6834a;
        if (i4 != 1) {
            if (i4 != 2) {
                return false;
            }
            a();
            C0747k.b0(revocationBoundService).c0();
            return true;
        }
        a();
        C0738b c0738bA = C0738b.a(revocationBoundService);
        GoogleSignInAccount googleSignInAccountB = c0738bA.b();
        GoogleSignInOptions googleSignInOptions = GoogleSignInOptions.f3342q;
        if (googleSignInAccountB != null) {
            String strD2 = c0738bA.d("defaultGoogleSignInAccount");
            if (TextUtils.isEmpty(strD2) || (strD = c0738bA.d(C0738b.f("googleSignInOptions", strD2))) == null) {
                googleSignInOptionsC = null;
                googleSignInOptions = googleSignInOptionsC;
            } else {
                try {
                    googleSignInOptionsC = GoogleSignInOptions.c(strD);
                } catch (JSONException unused) {
                    googleSignInOptionsC = null;
                }
                googleSignInOptions = googleSignInOptionsC;
            }
        }
        GoogleSignInOptions googleSignInOptions2 = googleSignInOptions;
        F.g(googleSignInOptions2);
        C0713a c0713a = new C0713a(revocationBoundService, null, AbstractC0660a.f6471a, googleSignInOptions2, new com.google.android.gms.common.api.k(new N(2), Looper.getMainLooper()));
        if (googleSignInAccountB != null) {
            c0713a.d();
        } else {
            c0713a.signOut();
        }
        return true;
    }
}
