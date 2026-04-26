package androidx.appcompat.view.menu;

import A.C;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;
import com.swing.live.R;
import f.AbstractC0398a;
import j.k;
import j.q;
import java.lang.reflect.Field;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class ListMenuItemView extends LinearLayout implements q, AbsListView.SelectionBoundsAdjuster {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public k f2657a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ImageView f2658b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public RadioButton f2659c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public TextView f2660d;
    public CheckBox e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public TextView f2661f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public ImageView f2662m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public ImageView f2663n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public LinearLayout f2664o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final Drawable f2665p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final int f2666q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final Context f2667r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public boolean f2668s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final Drawable f2669t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final boolean f2670u;
    public LayoutInflater v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public boolean f2671w;

    public ListMenuItemView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        C0747k c0747kP = C0747k.P(getContext(), attributeSet, AbstractC0398a.f4256n, R.attr.listMenuViewStyle);
        this.f2665p = c0747kP.F(5);
        TypedArray typedArray = (TypedArray) c0747kP.f6832c;
        this.f2666q = typedArray.getResourceId(1, -1);
        this.f2668s = typedArray.getBoolean(7, false);
        this.f2667r = context;
        this.f2669t = c0747kP.F(8);
        TypedArray typedArrayObtainStyledAttributes = context.getTheme().obtainStyledAttributes(null, new int[]{android.R.attr.divider}, R.attr.dropDownListViewStyle, 0);
        this.f2670u = typedArrayObtainStyledAttributes.hasValue(0);
        c0747kP.T();
        typedArrayObtainStyledAttributes.recycle();
    }

    private LayoutInflater getInflater() {
        if (this.v == null) {
            this.v = LayoutInflater.from(getContext());
        }
        return this.v;
    }

    private void setSubMenuArrowVisible(boolean z4) {
        ImageView imageView = this.f2662m;
        if (imageView != null) {
            imageView.setVisibility(z4 ? 0 : 8);
        }
    }

    @Override // android.widget.AbsListView.SelectionBoundsAdjuster
    public final void adjustListItemSelectionBounds(Rect rect) {
        ImageView imageView = this.f2663n;
        if (imageView == null || imageView.getVisibility() != 0) {
            return;
        }
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) this.f2663n.getLayoutParams();
        rect.top = this.f2663n.getHeight() + layoutParams.topMargin + layoutParams.bottomMargin + rect.top;
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x0037  */
    /* JADX WARN: Removed duplicated region for block: B:25:0x005a  */
    /* JADX WARN: Removed duplicated region for block: B:28:0x005e  */
    @Override // j.q
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void c(j.k r11) {
        /*
            Method dump skipped, instruction units count: 325
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.view.menu.ListMenuItemView.c(j.k):void");
    }

    @Override // j.q
    public k getItemData() {
        return this.f2657a;
    }

    @Override // android.view.View
    public final void onFinishInflate() {
        super.onFinishInflate();
        Field field = C.f4a;
        setBackground(this.f2665p);
        TextView textView = (TextView) findViewById(R.id.title);
        this.f2660d = textView;
        int i4 = this.f2666q;
        if (i4 != -1) {
            textView.setTextAppearance(this.f2667r, i4);
        }
        this.f2661f = (TextView) findViewById(R.id.shortcut);
        ImageView imageView = (ImageView) findViewById(R.id.submenuarrow);
        this.f2662m = imageView;
        if (imageView != null) {
            imageView.setImageDrawable(this.f2669t);
        }
        this.f2663n = (ImageView) findViewById(R.id.group_divider);
        this.f2664o = (LinearLayout) findViewById(R.id.content);
    }

    @Override // android.widget.LinearLayout, android.view.View
    public final void onMeasure(int i4, int i5) {
        if (this.f2658b != null && this.f2668s) {
            ViewGroup.LayoutParams layoutParams = getLayoutParams();
            LinearLayout.LayoutParams layoutParams2 = (LinearLayout.LayoutParams) this.f2658b.getLayoutParams();
            int i6 = layoutParams.height;
            if (i6 > 0 && layoutParams2.width <= 0) {
                layoutParams2.width = i6;
            }
        }
        super.onMeasure(i4, i5);
    }

    public void setCheckable(boolean z4) {
        CompoundButton compoundButton;
        View view;
        if (!z4 && this.f2659c == null && this.e == null) {
            return;
        }
        if ((this.f2657a.f5123x & 4) != 0) {
            if (this.f2659c == null) {
                RadioButton radioButton = (RadioButton) getInflater().inflate(R.layout.abc_list_menu_item_radio, (ViewGroup) this, false);
                this.f2659c = radioButton;
                LinearLayout linearLayout = this.f2664o;
                if (linearLayout != null) {
                    linearLayout.addView(radioButton, -1);
                } else {
                    addView(radioButton, -1);
                }
            }
            compoundButton = this.f2659c;
            view = this.e;
        } else {
            if (this.e == null) {
                CheckBox checkBox = (CheckBox) getInflater().inflate(R.layout.abc_list_menu_item_checkbox, (ViewGroup) this, false);
                this.e = checkBox;
                LinearLayout linearLayout2 = this.f2664o;
                if (linearLayout2 != null) {
                    linearLayout2.addView(checkBox, -1);
                } else {
                    addView(checkBox, -1);
                }
            }
            compoundButton = this.e;
            view = this.f2659c;
        }
        if (z4) {
            compoundButton.setChecked(this.f2657a.isChecked());
            if (compoundButton.getVisibility() != 0) {
                compoundButton.setVisibility(0);
            }
            if (view == null || view.getVisibility() == 8) {
                return;
            }
            view.setVisibility(8);
            return;
        }
        CheckBox checkBox2 = this.e;
        if (checkBox2 != null) {
            checkBox2.setVisibility(8);
        }
        RadioButton radioButton2 = this.f2659c;
        if (radioButton2 != null) {
            radioButton2.setVisibility(8);
        }
    }

    public void setChecked(boolean z4) {
        CompoundButton compoundButton;
        if ((this.f2657a.f5123x & 4) != 0) {
            if (this.f2659c == null) {
                RadioButton radioButton = (RadioButton) getInflater().inflate(R.layout.abc_list_menu_item_radio, (ViewGroup) this, false);
                this.f2659c = radioButton;
                LinearLayout linearLayout = this.f2664o;
                if (linearLayout != null) {
                    linearLayout.addView(radioButton, -1);
                } else {
                    addView(radioButton, -1);
                }
            }
            compoundButton = this.f2659c;
        } else {
            if (this.e == null) {
                CheckBox checkBox = (CheckBox) getInflater().inflate(R.layout.abc_list_menu_item_checkbox, (ViewGroup) this, false);
                this.e = checkBox;
                LinearLayout linearLayout2 = this.f2664o;
                if (linearLayout2 != null) {
                    linearLayout2.addView(checkBox, -1);
                } else {
                    addView(checkBox, -1);
                }
            }
            compoundButton = this.e;
        }
        compoundButton.setChecked(z4);
    }

    public void setForceShowIcon(boolean z4) {
        this.f2671w = z4;
        this.f2668s = z4;
    }

    public void setGroupDividerEnabled(boolean z4) {
        ImageView imageView = this.f2663n;
        if (imageView != null) {
            imageView.setVisibility((this.f2670u || !z4) ? 8 : 0);
        }
    }

    public void setIcon(Drawable drawable) {
        this.f2657a.f5114n.getClass();
        boolean z4 = this.f2671w;
        if (z4 || this.f2668s) {
            ImageView imageView = this.f2658b;
            if (imageView == null && drawable == null && !this.f2668s) {
                return;
            }
            if (imageView == null) {
                ImageView imageView2 = (ImageView) getInflater().inflate(R.layout.abc_list_menu_item_icon, (ViewGroup) this, false);
                this.f2658b = imageView2;
                LinearLayout linearLayout = this.f2664o;
                if (linearLayout != null) {
                    linearLayout.addView(imageView2, 0);
                } else {
                    addView(imageView2, 0);
                }
            }
            if (drawable == null && !this.f2668s) {
                this.f2658b.setVisibility(8);
                return;
            }
            ImageView imageView3 = this.f2658b;
            if (!z4) {
                drawable = null;
            }
            imageView3.setImageDrawable(drawable);
            if (this.f2658b.getVisibility() != 0) {
                this.f2658b.setVisibility(0);
            }
        }
    }

    public void setTitle(CharSequence charSequence) {
        if (charSequence == null) {
            if (this.f2660d.getVisibility() != 8) {
                this.f2660d.setVisibility(8);
            }
        } else {
            this.f2660d.setText(charSequence);
            if (this.f2660d.getVisibility() != 0) {
                this.f2660d.setVisibility(0);
            }
        }
    }
}
