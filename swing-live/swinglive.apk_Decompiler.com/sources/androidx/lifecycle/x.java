package androidx.lifecycle;

import android.app.Activity;
import android.app.Fragment;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

/* JADX INFO: loaded from: classes.dex */
public final class x extends AbstractC0217c {
    final /* synthetic */ y this$0;

    public static final class a extends AbstractC0217c {
        final /* synthetic */ y this$0;

        public a(y yVar) {
            this.this$0 = yVar;
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPostResumed(Activity activity) {
            J3.i.e(activity, "activity");
            this.this$0.a();
        }

        @Override // android.app.Application.ActivityLifecycleCallbacks
        public void onActivityPostStarted(Activity activity) {
            J3.i.e(activity, "activity");
            y yVar = this.this$0;
            int i4 = yVar.f3100a + 1;
            yVar.f3100a = i4;
            if (i4 == 1 && yVar.f3103d) {
                yVar.f3104f.e(EnumC0221g.ON_START);
                yVar.f3103d = false;
            }
        }
    }

    public x(y yVar) {
        this.this$0 = yVar;
    }

    @Override // androidx.lifecycle.AbstractC0217c, android.app.Application.ActivityLifecycleCallbacks
    public void onActivityCreated(Activity activity, Bundle bundle) {
        J3.i.e(activity, "activity");
        if (Build.VERSION.SDK_INT < 29) {
            int i4 = B.f3048b;
            Fragment fragmentFindFragmentByTag = activity.getFragmentManager().findFragmentByTag("androidx.lifecycle.LifecycleDispatcher.report_fragment_tag");
            J3.i.c(fragmentFindFragmentByTag, "null cannot be cast to non-null type androidx.lifecycle.ReportFragment");
            ((B) fragmentFindFragmentByTag).f3049a = this.this$0.f3106n;
        }
    }

    @Override // androidx.lifecycle.AbstractC0217c, android.app.Application.ActivityLifecycleCallbacks
    public void onActivityPaused(Activity activity) {
        J3.i.e(activity, "activity");
        y yVar = this.this$0;
        int i4 = yVar.f3101b - 1;
        yVar.f3101b = i4;
        if (i4 == 0) {
            Handler handler = yVar.e;
            J3.i.b(handler);
            handler.postDelayed(yVar.f3105m, 700L);
        }
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityPreCreated(Activity activity, Bundle bundle) {
        J3.i.e(activity, "activity");
        w.a(activity, new a(this.this$0));
    }

    @Override // androidx.lifecycle.AbstractC0217c, android.app.Application.ActivityLifecycleCallbacks
    public void onActivityStopped(Activity activity) {
        J3.i.e(activity, "activity");
        y yVar = this.this$0;
        int i4 = yVar.f3100a - 1;
        yVar.f3100a = i4;
        if (i4 == 0 && yVar.f3102c) {
            yVar.f3104f.e(EnumC0221g.ON_STOP);
            yVar.f3103d = true;
        }
    }
}
