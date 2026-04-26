package Y0;

import D2.AbstractActivityC0029d;
import Q3.F;
import Q3.O;
import Q3.z0;
import T2.t;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.swing.live.MainActivity;
import com.swing.live.R;
import d1.X;
import d1.r0;
import e1.AbstractC0367g;
import g.AbstractC0404a;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import java.security.GeneralSecurityException;
import java.util.HashSet;
import k.AbstractC0508z;
import k.C0498o;
import k.P;
import k.h0;
import t.AbstractC0669a;

/* JADX INFO: loaded from: classes.dex */
public final class n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f2488a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f2489b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f2490c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f2491d;
    public final Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Object f2492f;

    public n(MainActivity mainActivity, E2.c cVar) {
        J3.i.e(mainActivity, "activity");
        J3.i.e(cVar, "flutterEngine");
        this.f2488a = mainActivity;
        X3.e eVar = O.f1596a;
        R3.d dVar = V3.o.f2244a;
        z0 z0VarC = F.c();
        dVar.getClass();
        this.e = F.b(AbstractC0367g.A(dVar, z0VarC));
    }

    public static boolean a(int[] iArr, int i4) {
        for (int i5 : iArr) {
            if (i5 == i4) {
                return true;
            }
        }
        return false;
    }

    public static n b(String str, AbstractC0303h abstractC0303h, X x4, r0 r0Var, Integer num) throws GeneralSecurityException {
        if (r0Var == r0.RAW) {
            if (num != null) {
                throw new GeneralSecurityException("Keys with output prefix type raw should not have an id requirement.");
            }
        } else if (num == null) {
            throw new GeneralSecurityException("Keys with output prefix type different from raw should have an id requirement.");
        }
        return new n(str, abstractC0303h, x4, r0Var, num);
    }

    public static ColorStateList c(Context context, int i4) {
        int iB = h0.b(context, R.attr.colorControlHighlight);
        int iA = h0.a(context, R.attr.colorButtonNormal);
        int[] iArr = h0.f5372b;
        int[] iArr2 = h0.f5374d;
        int iB2 = AbstractC0669a.b(iB, i4);
        return new ColorStateList(new int[][]{iArr, iArr2, h0.f5373c, h0.f5375f}, new int[]{iA, iB2, AbstractC0669a.b(iB, i4), i4});
    }

    public static void e(Drawable drawable, int i4, PorterDuff.Mode mode) {
        PorterDuffColorFilter porterDuffColorFilterE;
        if (AbstractC0508z.a(drawable)) {
            drawable = drawable.mutate();
        }
        if (mode == null) {
            mode = C0498o.f5418b;
        }
        PorterDuff.Mode mode2 = C0498o.f5418b;
        synchronized (C0498o.class) {
            porterDuffColorFilterE = P.e(i4, mode);
        }
        drawable.setColorFilter(porterDuffColorFilterE);
    }

    public ColorStateList d(Context context, int i4) {
        if (i4 == R.drawable.abc_edit_text_material) {
            Object obj = AbstractC0404a.f4294a;
            return context.getColorStateList(R.color.abc_tint_edittext);
        }
        if (i4 == R.drawable.abc_switch_track_mtrl_alpha) {
            Object obj2 = AbstractC0404a.f4294a;
            return context.getColorStateList(R.color.abc_tint_switch_track);
        }
        if (i4 == R.drawable.abc_switch_thumb_material) {
            int[][] iArr = new int[3][];
            int[] iArr2 = new int[3];
            ColorStateList colorStateListC = h0.c(context, R.attr.colorSwitchThumbNormal);
            if (colorStateListC == null || !colorStateListC.isStateful()) {
                iArr[0] = h0.f5372b;
                iArr2[0] = h0.a(context, R.attr.colorSwitchThumbNormal);
                iArr[1] = h0.e;
                iArr2[1] = h0.b(context, R.attr.colorControlActivated);
                iArr[2] = h0.f5375f;
                iArr2[2] = h0.b(context, R.attr.colorSwitchThumbNormal);
            } else {
                int[] iArr3 = h0.f5372b;
                iArr[0] = iArr3;
                iArr2[0] = colorStateListC.getColorForState(iArr3, 0);
                iArr[1] = h0.e;
                iArr2[1] = h0.b(context, R.attr.colorControlActivated);
                iArr[2] = h0.f5375f;
                iArr2[2] = colorStateListC.getDefaultColor();
            }
            return new ColorStateList(iArr, iArr2);
        }
        if (i4 == R.drawable.abc_btn_default_mtrl_shape) {
            return c(context, h0.b(context, R.attr.colorButtonNormal));
        }
        if (i4 == R.drawable.abc_btn_borderless_material) {
            return c(context, 0);
        }
        if (i4 == R.drawable.abc_btn_colored_material) {
            return c(context, h0.b(context, R.attr.colorAccent));
        }
        if (i4 == R.drawable.abc_spinner_mtrl_am_alpha || i4 == R.drawable.abc_spinner_textfield_background_material) {
            Object obj3 = AbstractC0404a.f4294a;
            return context.getColorStateList(R.color.abc_tint_spinner);
        }
        if (a((int[]) this.f2489b, i4)) {
            return h0.c(context, R.attr.colorControlNormal);
        }
        if (a((int[]) this.e, i4)) {
            Object obj4 = AbstractC0404a.f4294a;
            return context.getColorStateList(R.color.abc_tint_default);
        }
        if (a((int[]) this.f2492f, i4)) {
            Object obj5 = AbstractC0404a.f4294a;
            return context.getColorStateList(R.color.abc_tint_btn_checkable);
        }
        if (i4 != R.drawable.abc_seekbar_thumb_material) {
            return null;
        }
        Object obj6 = AbstractC0404a.f4294a;
        return context.getColorStateList(R.color.abc_tint_seek_thumb);
    }

    public n(String str, AbstractC0303h abstractC0303h, X x4, r0 r0Var, Integer num) {
        this.f2488a = str;
        this.f2489b = s.b(str);
        this.f2490c = abstractC0303h;
        this.f2491d = x4;
        this.e = r0Var;
        this.f2492f = num;
    }

    public n() {
        this.f2488a = new int[]{R.drawable.abc_textfield_search_default_mtrl_alpha, R.drawable.abc_textfield_default_mtrl_alpha, R.drawable.abc_ab_share_pack_mtrl_alpha};
        this.f2489b = new int[]{R.drawable.abc_ic_commit_search_api_mtrl_alpha, R.drawable.abc_seekbar_tick_mark_material, R.drawable.abc_ic_menu_share_mtrl_alpha, R.drawable.abc_ic_menu_copy_mtrl_am_alpha, R.drawable.abc_ic_menu_cut_mtrl_alpha, R.drawable.abc_ic_menu_selectall_mtrl_alpha, R.drawable.abc_ic_menu_paste_mtrl_am_alpha};
        this.f2490c = new int[]{R.drawable.abc_textfield_activated_mtrl_alpha, R.drawable.abc_textfield_search_activated_mtrl_alpha, R.drawable.abc_cab_background_top_mtrl_alpha, R.drawable.abc_text_cursor_material, R.drawable.abc_text_select_handle_left_mtrl_dark, R.drawable.abc_text_select_handle_middle_mtrl_dark, R.drawable.abc_text_select_handle_right_mtrl_dark, R.drawable.abc_text_select_handle_left_mtrl_light, R.drawable.abc_text_select_handle_middle_mtrl_light, R.drawable.abc_text_select_handle_right_mtrl_light};
        this.f2491d = new int[]{R.drawable.abc_popup_background_mtrl_mult, R.drawable.abc_cab_background_internal_bg, R.drawable.abc_menu_hardkey_panel_mtrl_mult};
        this.e = new int[]{R.drawable.abc_tab_indicator_material, R.drawable.abc_textfield_search_material};
        this.f2492f = new int[]{R.drawable.abc_btn_check_material, R.drawable.abc_btn_radio_material, R.drawable.abc_btn_check_material_anim, R.drawable.abc_btn_radio_material_anim};
    }

    public n(String str, t tVar, t tVar2, t tVar3, t tVar4, Object obj) {
        this.f2488a = str;
        this.f2489b = tVar;
        this.f2490c = tVar2;
        this.f2491d = tVar3;
        this.e = tVar4;
        this.f2492f = obj;
    }

    public n(AbstractActivityC0029d abstractActivityC0029d, androidx.lifecycle.p pVar) {
        this.f2489b = new HashSet();
        this.f2490c = new HashSet();
        this.f2491d = new HashSet();
        this.e = new HashSet();
        new HashSet();
        this.f2492f = new HashSet();
        this.f2488a = abstractActivityC0029d;
        new HiddenLifecycleReference(pVar);
    }
}
