package io.flutter.plugin.platform;

import android.app.Presentation;
import android.content.Context;
import android.content.MutableContextWrapper;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import androidx.annotation.Keep;

/* JADX INFO: loaded from: classes.dex */
@Keep
class SingleViewPresentation extends Presentation {
    private static final String TAG = "PlatformViewsController";
    private final C0425a accessibilityEventsDelegate;
    private FrameLayout container;
    private final View.OnFocusChangeListener focusChangeListener;
    private final Context outerContext;
    private s rootView;
    private boolean startFocused;
    private final v state;
    private int viewId;

    public SingleViewPresentation(Context context, Display display, g gVar, C0425a c0425a, int i4, View.OnFocusChangeListener onFocusChangeListener) {
        super(new t(context, null), display);
        this.startFocused = false;
        this.accessibilityEventsDelegate = c0425a;
        this.viewId = i4;
        this.focusChangeListener = onFocusChangeListener;
        this.outerContext = context;
        v vVar = new v();
        this.state = vVar;
        vVar.f4692a = gVar;
        getWindow().setFlags(8, 8);
        getWindow().setType(2030);
    }

    public v detachState() {
        FrameLayout frameLayout = this.container;
        if (frameLayout != null) {
            frameLayout.removeAllViews();
        }
        s sVar = this.rootView;
        if (sVar != null) {
            sVar.removeAllViews();
        }
        return this.state;
    }

    public g getView() {
        return this.state.f4692a;
    }

    @Override // android.app.Dialog
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        getWindow().setBackgroundDrawable(new ColorDrawable(0));
        v vVar = this.state;
        if (vVar.f4694c == null) {
            vVar.f4694c = new r(getContext());
        }
        if (this.state.f4693b == null) {
            WindowManager windowManager = (WindowManager) getContext().getSystemService("window");
            v vVar2 = this.state;
            vVar2.f4693b = new D(windowManager, vVar2.f4694c);
        }
        this.container = new FrameLayout(getContext());
        u uVar = new u(getContext(), this.state.f4693b, this.outerContext);
        FrameLayout frameLayout = ((y2.k) this.state.f4692a).f6916c;
        if (frameLayout.getContext() instanceof MutableContextWrapper) {
            ((MutableContextWrapper) frameLayout.getContext()).setBaseContext(uVar);
        } else {
            Log.w(TAG, "Unexpected platform view context for view ID " + this.viewId + "; some functionality may not work correctly. When constructing a platform view in the factory, ensure that the view returned from PlatformViewFactory#create returns the provided context from getContext(). If you are unable to associate the view with that context, consider using Hybrid Composition instead.");
        }
        this.container.addView(frameLayout);
        s sVar = new s(getContext(), this.accessibilityEventsDelegate, frameLayout);
        this.rootView = sVar;
        sVar.addView(this.container);
        this.rootView.addView(this.state.f4694c);
        frameLayout.setOnFocusChangeListener(this.focusChangeListener);
        this.rootView.setFocusableInTouchMode(true);
        if (this.startFocused) {
            frameLayout.requestFocus();
        } else {
            this.rootView.requestFocus();
        }
        setContentView(this.rootView);
    }

    public SingleViewPresentation(Context context, Display display, C0425a c0425a, v vVar, View.OnFocusChangeListener onFocusChangeListener, boolean z4) {
        super(new t(context, null), display);
        this.startFocused = false;
        this.accessibilityEventsDelegate = c0425a;
        this.state = vVar;
        this.focusChangeListener = onFocusChangeListener;
        this.outerContext = context;
        getWindow().setFlags(8, 8);
        this.startFocused = z4;
    }
}
