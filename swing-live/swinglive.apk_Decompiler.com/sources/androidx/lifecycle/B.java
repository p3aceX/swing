package androidx.lifecycle;

import android.app.Activity;
import android.app.Application;
import android.app.Fragment;
import android.os.Build;
import android.os.Bundle;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class B extends Fragment {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ int f3048b = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0779j f3049a;

    public static final class a implements Application.ActivityLifecycleCallbacks {
        public static final A Companion = new A();

        public static final void registerIn(Activity activity) {
            Companion.getClass();
            J3.i.e(activity, "activity");
            activity.registerActivityLifecycleCallbacks(new a());
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityCreated(Activity activity, Bundle bundle) {
            J3.i.e(activity, "activity");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityDestroyed(Activity activity) {
            J3.i.e(activity, "activity");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPaused(Activity activity) {
            J3.i.e(activity, "activity");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPostCreated(Activity activity, Bundle bundle) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_CREATE);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPostResumed(Activity activity) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_RESUME);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPostStarted(Activity activity) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_START);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPreDestroyed(Activity activity) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_DESTROY);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPrePaused(Activity activity) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_PAUSE);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPreStopped(Activity activity) {
            J3.i.e(activity, "activity");
            int i4 = B.f3048b;
            z.a(activity, EnumC0221g.ON_STOP);
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityResumed(Activity activity) {
            J3.i.e(activity, "activity");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            J3.i.e(activity, "activity");
            J3.i.e(bundle, "bundle");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityStarted(Activity activity) {
            J3.i.e(activity, "activity");
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityStopped(Activity activity) {
            J3.i.e(activity, "activity");
        }
    }

    public final void a(EnumC0221g enumC0221g) {
        if (Build.VERSION.SDK_INT < 29) {
            Activity activity = getActivity();
            J3.i.d(activity, "activity");
            z.a(activity, enumC0221g);
        }
    }

    @Override // android.app.Fragment
    public final void onActivityCreated(Bundle bundle) {
        super.onActivityCreated(bundle);
        a(EnumC0221g.ON_CREATE);
    }

    @Override // android.app.Fragment
    public final void onDestroy() {
        super.onDestroy();
        a(EnumC0221g.ON_DESTROY);
        this.f3049a = null;
    }

    @Override // android.app.Fragment
    public final void onPause() {
        super.onPause();
        a(EnumC0221g.ON_PAUSE);
    }

    @Override // android.app.Fragment
    public final void onResume() {
        super.onResume();
        C0779j c0779j = this.f3049a;
        if (c0779j != null) {
            ((y) c0779j.f6969b).a();
        }
        a(EnumC0221g.ON_RESUME);
    }

    @Override // android.app.Fragment
    public final void onStart() {
        super.onStart();
        C0779j c0779j = this.f3049a;
        if (c0779j != null) {
            y yVar = (y) c0779j.f6969b;
            int i4 = yVar.f3100a + 1;
            yVar.f3100a = i4;
            if (i4 == 1 && yVar.f3103d) {
                yVar.f3104f.e(EnumC0221g.ON_START);
                yVar.f3103d = false;
            }
        }
        a(EnumC0221g.ON_START);
    }

    @Override // android.app.Fragment
    public final void onStop() {
        super.onStop();
        a(EnumC0221g.ON_STOP);
    }
}
