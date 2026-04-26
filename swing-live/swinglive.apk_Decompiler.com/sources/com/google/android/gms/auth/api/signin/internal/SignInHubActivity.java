package com.google.android.gms.auth.api.signin.internal;

import B.k;
import D2.B;
import D2.v;
import O.AbstractActivityC0114z;
import R.a;
import R.b;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.os.Looper;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.SignInAccount;
import com.google.android.gms.common.annotation.KeepName;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.o;
import java.lang.reflect.Modifier;
import java.util.Set;
import n.l;
import y0.C0738b;
import y0.C0740d;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
@KeepName
public class SignInHubActivity extends AbstractActivityC0114z {

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public static boolean f3362H = false;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public boolean f3363C = false;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public SignInConfiguration f3364D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public boolean f3365E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public int f3366F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public Intent f3367G;

    @Override // android.app.Activity, android.view.Window.Callback
    public final boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent accessibilityEvent) {
        return true;
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    public final void k() {
        v vVar = new v(this, g());
        k kVar = new k(this, 28);
        b bVar = (b) vVar.f261c;
        if (bVar.f1678d) {
            throw new IllegalStateException("Called while creating a loader");
        }
        if (Looper.getMainLooper() != Looper.myLooper()) {
            throw new IllegalStateException("initLoader must be called on the main thread");
        }
        l lVar = bVar.f1677c;
        a aVar = (a) lVar.b(0, null);
        if (aVar == null) {
            try {
                bVar.f1678d = true;
                Set set = o.f3502a;
                synchronized (set) {
                }
                C0740d c0740d = new C0740d(this, set);
                if (C0740d.class.isMemberClass() && !Modifier.isStatic(C0740d.class.getModifiers())) {
                    throw new IllegalArgumentException("Object returned from onCreateLoader must not be a non-static inner member class: " + c0740d);
                }
                a aVar2 = new a(c0740d);
                lVar.c(0, aVar2);
                bVar.f1678d = false;
                B b5 = new B(aVar2.f1674l, kVar);
                aVar2.d(this, b5);
                B b6 = aVar2.f1676n;
                if (b6 != null) {
                    aVar2.g(b6);
                }
                aVar2.f1675m = this;
                aVar2.f1676n = b5;
            } catch (Throwable th) {
                bVar.f1678d = false;
                throw th;
            }
        } else {
            B b7 = new B(aVar.f1674l, kVar);
            aVar.d(this, b7);
            B b8 = aVar.f1676n;
            if (b8 != null) {
                aVar.g(b8);
            }
            aVar.f1675m = this;
            aVar.f1676n = b7;
        }
        f3362H = false;
    }

    public final void l(int i4) {
        Status status = new Status(i4, null);
        Intent intent = new Intent();
        intent.putExtra("googleSignInStatus", status);
        setResult(0, intent);
        finish();
        f3362H = false;
    }

    @Override // O.AbstractActivityC0114z, b.AbstractActivityC0234k, android.app.Activity
    public final void onActivityResult(int i4, int i5, Intent intent) {
        GoogleSignInAccount googleSignInAccount;
        if (this.f3363C) {
            return;
        }
        setResult(0);
        if (i4 != 40962) {
            return;
        }
        if (intent != null) {
            SignInAccount signInAccount = (SignInAccount) intent.getParcelableExtra("signInAccount");
            if (signInAccount != null && (googleSignInAccount = signInAccount.f3358b) != null) {
                C0747k c0747kB0 = C0747k.b0(this);
                GoogleSignInOptions googleSignInOptions = this.f3364D.f3361b;
                synchronized (c0747kB0) {
                    ((C0738b) c0747kB0.f6831b).c(googleSignInAccount, googleSignInOptions);
                    c0747kB0.f6832c = googleSignInAccount;
                    c0747kB0.f6833d = googleSignInOptions;
                }
                intent.removeExtra("signInAccount");
                intent.putExtra("googleSignInAccount", googleSignInAccount);
                this.f3365E = true;
                this.f3366F = i5;
                this.f3367G = intent;
                k();
                return;
            }
            if (intent.hasExtra("errorCode")) {
                int intExtra = intent.getIntExtra("errorCode", 8);
                if (intExtra == 13) {
                    intExtra = 12501;
                }
                l(intExtra);
                return;
            }
        }
        l(8);
    }

    @Override // O.AbstractActivityC0114z, b.AbstractActivityC0234k, q.i, android.app.Activity
    public final void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        Intent intent = getIntent();
        String action = intent.getAction();
        action.getClass();
        if ("com.google.android.gms.auth.NO_IMPL".equals(action)) {
            l(12500);
            return;
        }
        if (!action.equals("com.google.android.gms.auth.GOOGLE_SIGN_IN") && !action.equals("com.google.android.gms.auth.APPAUTH_SIGN_IN")) {
            Log.e("AuthSignInClient", "Unknown action: ".concat(String.valueOf(intent.getAction())));
            finish();
            return;
        }
        Bundle bundleExtra = intent.getBundleExtra("config");
        bundleExtra.getClass();
        SignInConfiguration signInConfiguration = (SignInConfiguration) bundleExtra.getParcelable("config");
        if (signInConfiguration == null) {
            Log.e("AuthSignInClient", "Activity started with invalid configuration.");
            setResult(0);
            finish();
            return;
        }
        this.f3364D = signInConfiguration;
        if (bundle != null) {
            boolean z4 = bundle.getBoolean("signingInGoogleApiClients");
            this.f3365E = z4;
            if (z4) {
                this.f3366F = bundle.getInt("signInResultCode");
                Intent intent2 = (Intent) bundle.getParcelable("signInResultData");
                intent2.getClass();
                this.f3367G = intent2;
                k();
                return;
            }
            return;
        }
        if (f3362H) {
            setResult(0);
            l(12502);
            return;
        }
        f3362H = true;
        Intent intent3 = new Intent(action);
        if (action.equals("com.google.android.gms.auth.GOOGLE_SIGN_IN")) {
            intent3.setPackage("com.google.android.gms");
        } else {
            intent3.setPackage(getPackageName());
        }
        intent3.putExtra("config", this.f3364D);
        try {
            startActivityForResult(intent3, 40962);
        } catch (ActivityNotFoundException unused) {
            this.f3363C = true;
            Log.w("AuthSignInClient", "Could not launch sign in Intent. Google Play Service is probably being updated...");
            l(17);
        }
    }

    @Override // O.AbstractActivityC0114z, android.app.Activity
    public final void onDestroy() {
        super.onDestroy();
        f3362H = false;
    }

    @Override // b.AbstractActivityC0234k, q.i, android.app.Activity
    public final void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        bundle.putBoolean("signingInGoogleApiClients", this.f3365E);
        if (this.f3365E) {
            bundle.putInt("signInResultCode", this.f3366F);
            bundle.putParcelable("signInResultData", this.f3367G);
        }
    }
}
