package com.google.android.gms.common.api.internal;

import android.R;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.os.IInterface;
import android.util.Log;
import android.widget.ProgressBar;
import com.google.android.gms.common.api.GoogleApiActivity;
import com.google.android.gms.common.internal.AbstractBinderC0278a;
import com.google.android.gms.common.internal.InterfaceC0290m;
import com.google.android.gms.internal.base.zaq;
import java.util.Set;
import z0.AbstractC0778i;
import z0.C0771b;
import z0.C0774e;

/* JADX INFO: loaded from: classes.dex */
public final class Z implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3446a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f3447b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f3448c;

    public /* synthetic */ Z(int i4, Object obj, Object obj2) {
        this.f3446a = i4;
        this.f3448c = obj;
        this.f3447b = obj2;
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$PrimitiveArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // java.lang.Runnable
    public final void run() {
        InterfaceC0290m interfaceC0290m;
        Set set;
        InterfaceC0290m s4 = null;
        switch (this.f3446a) {
            case 0:
                if (((DialogInterfaceOnCancelListenerC0277z) this.f3448c).f3494a) {
                    C0771b c0771b = ((Y) this.f3447b).f3445b;
                    if ((c0771b.f6949b == 0 || c0771b.f6950c == null) ? false : true) {
                        DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                        InterfaceC0263k interfaceC0263k = dialogInterfaceOnCancelListenerC0277z.mLifecycleFragment;
                        Activity activity = dialogInterfaceOnCancelListenerC0277z.getActivity();
                        PendingIntent pendingIntent = c0771b.f6950c;
                        com.google.android.gms.common.internal.F.g(pendingIntent);
                        int i4 = ((Y) this.f3447b).f3444a;
                        int i5 = GoogleApiActivity.f3368b;
                        Intent intent = new Intent(activity, (Class<?>) GoogleApiActivity.class);
                        intent.putExtra("pending_intent", pendingIntent);
                        intent.putExtra("failing_client_id", i4);
                        intent.putExtra("notify_manager", false);
                        interfaceC0263k.f(1, intent);
                        return;
                    }
                    DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z2 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                    if (dialogInterfaceOnCancelListenerC0277z2.f3497d.a(dialogInterfaceOnCancelListenerC0277z2.getActivity(), c0771b.f6949b, null) != null) {
                        DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z3 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                        C0774e c0774e = dialogInterfaceOnCancelListenerC0277z3.f3497d;
                        Activity activity2 = dialogInterfaceOnCancelListenerC0277z3.getActivity();
                        DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z4 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                        c0774e.h(activity2, dialogInterfaceOnCancelListenerC0277z4.mLifecycleFragment, c0771b.f6949b, dialogInterfaceOnCancelListenerC0277z4);
                        return;
                    }
                    if (c0771b.f6949b != 18) {
                        DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z5 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                        int i6 = ((Y) this.f3447b).f3444a;
                        dialogInterfaceOnCancelListenerC0277z5.f3495b.set(null);
                        dialogInterfaceOnCancelListenerC0277z5.f3498f.h(c0771b, i6);
                        return;
                    }
                    DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z6 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                    C0774e c0774e2 = dialogInterfaceOnCancelListenerC0277z6.f3497d;
                    Activity activity3 = dialogInterfaceOnCancelListenerC0277z6.getActivity();
                    DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z7 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                    c0774e2.getClass();
                    ProgressBar progressBar = new ProgressBar(activity3, null, R.attr.progressBarStyleLarge);
                    progressBar.setIndeterminate(true);
                    progressBar.setVisibility(0);
                    AlertDialog.Builder builder = new AlertDialog.Builder(activity3);
                    builder.setView(progressBar);
                    builder.setMessage(com.google.android.gms.common.internal.x.b(activity3, 18));
                    builder.setPositiveButton("", (DialogInterface.OnClickListener) null);
                    AlertDialog alertDialogCreate = builder.create();
                    C0774e.f(activity3, alertDialogCreate, "GooglePlayServicesUpdatingDialog", dialogInterfaceOnCancelListenerC0277z7);
                    DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z8 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                    C0774e c0774e3 = dialogInterfaceOnCancelListenerC0277z8.f3497d;
                    Context applicationContext = dialogInterfaceOnCancelListenerC0277z8.getActivity().getApplicationContext();
                    C0276y c0276y = new C0276y(this, alertDialogCreate);
                    c0774e3.getClass();
                    IntentFilter intentFilter = new IntentFilter("android.intent.action.PACKAGE_ADDED");
                    intentFilter.addDataScheme("package");
                    I i7 = new I(c0276y);
                    applicationContext.registerReceiver(i7, intentFilter);
                    i7.f3413a = applicationContext;
                    if (AbstractC0778i.b(applicationContext)) {
                        return;
                    }
                    DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z9 = (DialogInterfaceOnCancelListenerC0277z) this.f3448c;
                    dialogInterfaceOnCancelListenerC0277z9.f3495b.set(null);
                    zaq zaqVar = dialogInterfaceOnCancelListenerC0277z9.f3498f.f3481n;
                    zaqVar.sendMessage(zaqVar.obtainMessage(3));
                    if (alertDialogCreate.isShowing()) {
                        alertDialogCreate.dismiss();
                    }
                    synchronized (i7) {
                        try {
                            Context context = i7.f3413a;
                            if (context != null) {
                                context.unregisterReceiver(i7);
                            }
                            i7.f3413a = null;
                        } catch (Throwable th) {
                            throw th;
                        }
                    }
                    return;
                }
                return;
            case 1:
                G g4 = (G) this.f3448c;
                E e = (E) g4.f3411f.f3477j.get(g4.f3408b);
                if (e == null) {
                    return;
                }
                C0771b c0771b2 = (C0771b) this.f3447b;
                if (!(c0771b2.f6949b == 0)) {
                    e.p(c0771b2, null);
                    return;
                }
                g4.e = true;
                com.google.android.gms.common.api.g gVar = g4.f3407a;
                if (gVar.requiresSignIn()) {
                    if (!g4.e || (interfaceC0290m = g4.f3409c) == null) {
                        return;
                    }
                    gVar.getRemoteService(interfaceC0290m, g4.f3410d);
                    return;
                }
                try {
                    gVar.getRemoteService(null, gVar.getScopesForConnectionlessNonSignIn());
                    return;
                } catch (SecurityException e4) {
                    Log.e("GoogleApiManager", "Failed to get service from broker. ", e4);
                    gVar.disconnect("Failed to get service from broker.");
                    e.p(new C0771b(10), null);
                    return;
                }
            default:
                P0.g gVar2 = (P0.g) this.f3447b;
                C0771b c0771b3 = gVar2.f1488b;
                boolean z4 = c0771b3.f6949b == 0;
                O o4 = (O) this.f3448c;
                if (z4) {
                    com.google.android.gms.common.internal.B b5 = gVar2.f1489c;
                    com.google.android.gms.common.internal.F.g(b5);
                    C0771b c0771b4 = b5.f3511c;
                    if (c0771b4.f6949b != 0) {
                        Log.wtf("SignInCoordinator", "Sign-in succeeded with resolve account failure: ".concat(String.valueOf(c0771b4)), new Exception());
                        o4.f3432g.b(c0771b4);
                        o4.f3431f.disconnect();
                        return;
                    }
                    G g5 = o4.f3432g;
                    IBinder iBinder = b5.f3510b;
                    if (iBinder != null) {
                        int i8 = AbstractBinderC0278a.f3553a;
                        IInterface iInterfaceQueryLocalInterface = iBinder.queryLocalInterface("com.google.android.gms.common.internal.IAccountAccessor");
                        s4 = iInterfaceQueryLocalInterface instanceof InterfaceC0290m ? (InterfaceC0290m) iInterfaceQueryLocalInterface : new com.google.android.gms.common.internal.S(iBinder, "com.google.android.gms.common.internal.IAccountAccessor");
                    }
                    g5.getClass();
                    if (s4 == null || (set = o4.f3430d) == null) {
                        Log.wtf("GoogleApiManager", "Received null response from onSignInSuccess", new Exception());
                        g5.b(new C0771b(4));
                    } else {
                        g5.f3409c = s4;
                        g5.f3410d = set;
                        if (g5.e) {
                            g5.f3407a.getRemoteService(s4, set);
                        }
                    }
                } else {
                    o4.f3432g.b(c0771b3);
                }
                o4.f3431f.disconnect();
                return;
        }
    }
}
