package b;

import android.app.Dialog;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.window.OnBackInvokedDispatcher;
import androidx.lifecycle.EnumC0221g;
import com.swing.live.R;

/* JADX INFO: renamed from: b.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class DialogC0235l extends Dialog implements androidx.lifecycle.n, v, Y.g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public androidx.lifecycle.p f3243a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Y.f f3244b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final u f3245c;

    public DialogC0235l(Context context, int i4) {
        super(context, i4);
        this.f3244b = new Y.f(this);
        this.f3245c = new u(new F1.a(this, 15));
    }

    public static void a(DialogC0235l dialogC0235l) {
        J3.i.e(dialogC0235l, "this$0");
        super.onBackPressed();
    }

    @Override // android.app.Dialog
    public final void addContentView(View view, ViewGroup.LayoutParams layoutParams) {
        J3.i.e(view, "view");
        d();
        super.addContentView(view, layoutParams);
    }

    @Override // b.v
    public final u b() {
        return this.f3245c;
    }

    @Override // Y.g
    public final Y.e c() {
        return (Y.e) this.f3244b.f2464c;
    }

    public final void d() {
        Window window = getWindow();
        J3.i.b(window);
        View decorView = window.getDecorView();
        J3.i.d(decorView, "window!!.decorView");
        decorView.setTag(R.id.view_tree_lifecycle_owner, this);
        Window window2 = getWindow();
        J3.i.b(window2);
        View decorView2 = window2.getDecorView();
        J3.i.d(decorView2, "window!!.decorView");
        decorView2.setTag(R.id.view_tree_on_back_pressed_dispatcher_owner, this);
        Window window3 = getWindow();
        J3.i.b(window3);
        View decorView3 = window3.getDecorView();
        J3.i.d(decorView3, "window!!.decorView");
        decorView3.setTag(R.id.view_tree_saved_state_registry_owner, this);
    }

    @Override // androidx.lifecycle.n
    public final androidx.lifecycle.p i() {
        androidx.lifecycle.p pVar = this.f3243a;
        if (pVar != null) {
            return pVar;
        }
        androidx.lifecycle.p pVar2 = new androidx.lifecycle.p(this);
        this.f3243a = pVar2;
        return pVar2;
    }

    @Override // android.app.Dialog
    public final void onBackPressed() {
        this.f3245c.a();
    }

    @Override // android.app.Dialog
    public final void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (Build.VERSION.SDK_INT >= 33) {
            OnBackInvokedDispatcher onBackInvokedDispatcher = getOnBackInvokedDispatcher();
            J3.i.d(onBackInvokedDispatcher, "onBackInvokedDispatcher");
            u uVar = this.f3245c;
            uVar.getClass();
            uVar.e = onBackInvokedDispatcher;
            uVar.b(uVar.f3268g);
        }
        this.f3244b.c(bundle);
        androidx.lifecycle.p pVar = this.f3243a;
        if (pVar == null) {
            pVar = new androidx.lifecycle.p(this);
            this.f3243a = pVar;
        }
        pVar.e(EnumC0221g.ON_CREATE);
    }

    @Override // android.app.Dialog
    public final Bundle onSaveInstanceState() {
        Bundle bundleOnSaveInstanceState = super.onSaveInstanceState();
        J3.i.d(bundleOnSaveInstanceState, "super.onSaveInstanceState()");
        this.f3244b.d(bundleOnSaveInstanceState);
        return bundleOnSaveInstanceState;
    }

    @Override // android.app.Dialog
    public final void onStart() {
        super.onStart();
        androidx.lifecycle.p pVar = this.f3243a;
        if (pVar == null) {
            pVar = new androidx.lifecycle.p(this);
            this.f3243a = pVar;
        }
        pVar.e(EnumC0221g.ON_RESUME);
    }

    @Override // android.app.Dialog
    public final void onStop() {
        androidx.lifecycle.p pVar = this.f3243a;
        if (pVar == null) {
            pVar = new androidx.lifecycle.p(this);
            this.f3243a = pVar;
        }
        pVar.e(EnumC0221g.ON_DESTROY);
        this.f3243a = null;
        super.onStop();
    }

    @Override // android.app.Dialog
    public final void setContentView(int i4) {
        d();
        super.setContentView(i4);
    }

    @Override // android.app.Dialog
    public final void setContentView(View view) {
        J3.i.e(view, "view");
        d();
        super.setContentView(view);
    }

    @Override // android.app.Dialog
    public final void setContentView(View view, ViewGroup.LayoutParams layoutParams) {
        J3.i.e(view, "view");
        d();
        super.setContentView(view, layoutParams);
    }
}
