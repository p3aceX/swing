package j;

import android.view.View;
import android.view.ViewConfiguration;
import androidx.appcompat.view.menu.ActionMenuItemView;
import k.C0489f;
import k.C0490g;
import k.C0491h;
import k.RunnableC0476D;

/* JADX INFO: loaded from: classes.dex */
public final class a implements View.OnTouchListener, View.OnAttachStateChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f5031a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f5032b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5033c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final View f5034d;
    public RunnableC0476D e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public RunnableC0476D f5035f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f5036m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f5037n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int[] f5038o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final /* synthetic */ int f5039p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final /* synthetic */ View f5040q;

    public a(View view) {
        this.f5038o = new int[2];
        this.f5034d = view;
        view.setLongClickable(true);
        view.addOnAttachStateChangeListener(this);
        this.f5031a = ViewConfiguration.get(view.getContext()).getScaledTouchSlop();
        int tapTimeout = ViewConfiguration.getTapTimeout();
        this.f5032b = tapTimeout;
        this.f5033c = (ViewConfiguration.getLongPressTimeout() + tapTimeout) / 2;
    }

    public final void a() {
        RunnableC0476D runnableC0476D = this.f5035f;
        View view = this.f5034d;
        if (runnableC0476D != null) {
            view.removeCallbacks(runnableC0476D);
        }
        RunnableC0476D runnableC0476D2 = this.e;
        if (runnableC0476D2 != null) {
            view.removeCallbacks(runnableC0476D2);
        }
    }

    public final l b() {
        C0489f c0489f;
        switch (this.f5039p) {
            case 0:
                b bVar = ((ActionMenuItemView) this.f5040q).f2650p;
                if (bVar == null || (c0489f = ((C0490g) bVar).f5369a.f5395y) == null) {
                    return null;
                }
                return c0489f.a();
            default:
                C0489f c0489f2 = ((C0491h) this.f5040q).f5370c.f5394x;
                if (c0489f2 == null) {
                    return null;
                }
                return c0489f2.a();
        }
    }

    public final boolean c() {
        l lVarB;
        switch (this.f5039p) {
            case 0:
                ActionMenuItemView actionMenuItemView = (ActionMenuItemView) this.f5040q;
                i iVar = actionMenuItemView.f2648n;
                return iVar != null && iVar.a(actionMenuItemView.e) && (lVarB = b()) != null && lVarB.g();
            default:
                ((C0491h) this.f5040q).f5370c.h();
                return true;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:22:0x005e  */
    /* JADX WARN: Removed duplicated region for block: B:35:0x0086  */
    /* JADX WARN: Removed duplicated region for block: B:61:0x00ef  */
    /* JADX WARN: Removed duplicated region for block: B:71:0x0124  */
    @Override // android.view.View.OnTouchListener
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean onTouch(android.view.View r13, android.view.MotionEvent r14) {
        /*
            Method dump skipped, instruction units count: 326
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: j.a.onTouch(android.view.View, android.view.MotionEvent):boolean");
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewDetachedFromWindow(View view) {
        this.f5036m = false;
        this.f5037n = -1;
        RunnableC0476D runnableC0476D = this.e;
        if (runnableC0476D != null) {
            this.f5034d.removeCallbacks(runnableC0476D);
        }
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public a(ActionMenuItemView actionMenuItemView) {
        this((View) actionMenuItemView);
        this.f5039p = 0;
        this.f5040q = actionMenuItemView;
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public a(C0491h c0491h, C0491h c0491h2) {
        this(c0491h2);
        this.f5039p = 1;
        this.f5040q = c0491h;
    }

    @Override // android.view.View.OnAttachStateChangeListener
    public final void onViewAttachedToWindow(View view) {
    }
}
